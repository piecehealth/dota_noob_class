# frozen_string_literal: true

# Job to sync all active students' matches and ranks in batches
# Uses GraphQL batch queries to minimize API requests
# Automatically skips invalid Steam IDs
class BatchSyncAllPlayersJob < ApplicationJob
  queue_as :default

  retry_on StratzApi::RateLimitError, wait: 1.minute, attempts: 3

  def perform(since_days: 14)
    users = User.active_students
    total_users = users.count

    Rails.logger.info "[BatchSync] 开始同步 #{total_users} 个用户 (过去 #{since_days} 天)"

    processed = 0
    cleaned = 0
    errors = []

    api = StratzApi.new

    # Process in batches
    users.each_slice(StratzApi::BATCH_SIZE) do |batch_users|
      # 先检查并标记不合法的 Steam ID（非纯数字）
      invalid_format_users = batch_users.select { |u| u.dota2_player_id.to_s !~ /^\d+$/ }
      invalid_format_users.each do |user|
        user_info = "#{user.classroom&.number}班#{user.group&.number}组#{user.display_name}"
        Rails.logger.warn "[BatchSync] #{user_info} Steam ID 格式不合法: #{user.dota2_player_id.inspect}，已标记"
        user.update_column(:is_dota2_id_invalid, true)
        cleaned += 1
      end

      # 过滤掉不合法的用户
      batch_users = batch_users.reject { |u| u.is_dota2_id_invalid? }

      # Build mapping for this batch
      batch_map = batch_users.index_by { |u| u.dota2_player_id.to_s }
      batch_ids = batch_map.keys.compact

      next if batch_ids.empty?

      # 打印批次信息
      user_info_list = batch_users.map { |u| "#{u.classroom&.number}班#{u.group&.number}组#{u.display_name}" }
      Rails.logger.info "[BatchSync] 正在同步: #{user_info_list.join(', ')}"

      begin
        # Try to sync the whole batch
        api.batch_sync_players(batch_ids, since_days: since_days, users_by_steam_id: batch_map)
        processed += batch_ids.size
        Rails.logger.info "[BatchSync] 成功同步 #{batch_ids.size} 个用户"
        sleep 1
      rescue StratzApi::ApiError => e
        if e.message.include?("missing or anonymous")
          # Extract invalid Steam IDs from error message
          invalid_ids = e.message.scan(/Player Id is missing or anonymous : (\d+)/).flatten

          # Mark invalid Steam IDs
          invalid_ids.each do |invalid_id|
            user = batch_map[invalid_id]
            if user
              user_info = "#{user.classroom&.number}班#{user.group&.number}组#{user.display_name}"
              Rails.logger.warn "[BatchSync] #{user_info} Steam ID 无效 (missing/anonymous): #{invalid_id}，已标记"
              user.update_column(:is_dota2_id_invalid, true)
              cleaned += 1
            end
          end

          # Retry with remaining valid users
          valid_users = batch_users.reject { |u| invalid_ids.include?(u.dota2_player_id.to_s) }
          if valid_users.any?
            valid_map = valid_users.index_by { |u| u.dota2_player_id.to_s }
            valid_ids = valid_map.keys.compact

            if valid_ids.empty?
              next
            end

            valid_info_list = valid_users.map { |u| "#{u.classroom&.number}班#{u.group&.number}组#{u.display_name}" }
            Rails.logger.info "[BatchSync] 重试有效用户: #{valid_info_list.join(', ')}"
            begin
              api.batch_sync_players(valid_ids, since_days: since_days, users_by_steam_id: valid_map)
              processed += valid_ids.size
              Rails.logger.info "[BatchSync] ✓ 成功同步 #{valid_ids.size} 个有效用户"
            rescue => retry_error
              Rails.logger.error "[BatchSync] 重试失败: #{retry_error.message}"
              errors << { batch_size: valid_ids.size, error: retry_error.message }
            end
          else
            Rails.logger.info "[BatchSync] 批次中所有 Steam ID 都无效，跳过"
          end
        else
          Rails.logger.error "[BatchSync] API 错误: #{e.message}"
          errors << { batch_size: batch_ids.size, error: e.message }
        end
      rescue => e
        Rails.logger.error "[BatchSync] 意外错误: #{e.message}"
        errors << { batch_size: batch_ids.size, error: e.message }
      end
    end

    Rails.logger.info "[BatchSync] 更新 #{users.count} 个用户的段位信息..."

    users.each_slice(StratzApi::BATCH_SIZE) do |batch_users|
      # 过滤掉不合法的 Steam ID
      batch_users = batch_users.reject { |u| u.is_dota2_id_invalid? }

      batch_map = batch_users.index_by { |u| u.dota2_player_id.to_s }
      batch_ids = batch_map.keys

      next if batch_ids.empty?

      begin
        profiles = api.batch_player_profiles(batch_ids)

        batch_ids.each do |player_id|
          user = batch_map[player_id]
          next unless user

          profile = profiles[player_id.to_i]
          if profile
            update_user_rank(user, profile)
            RankSnapshot.capture_for_user(user, profile)
          end
        end
        sleep 1
      rescue => e
        Rails.logger.error "[BatchSync] 更新段位失败: #{e.message}"
      end
    end

    Rails.logger.info "[BatchSync] 同步完成: #{processed}/#{total_users} 用户, #{cleaned} 个无效 ID 标记, #{errors.count} 个错误"

    # After all matches are synced, calculate daily stats for yesterday
    CalculateDailyStatsJob.perform_later(Date.yesterday)

    {
      total_users: total_users,
      processed: processed,
      cleaned: cleaned,
      errors: errors.count
    }
  end

  private

  def update_user_rank(user, profile)
    new_rank = profile[:rank] || 0
    new_highest = [ user.highest_rank, new_rank ].max

    user.update!(
      current_rank: new_rank,
      highest_rank: new_highest,
      total_matches: profile[:match_count] || 0,
      total_wins: profile[:win_count] || 0,
      rank_updated_at: Time.current
    )
  rescue => e
    Rails.logger.error "[BatchSync] 更新段位失败 #{user.id}: #{e.message}"
  end
end
