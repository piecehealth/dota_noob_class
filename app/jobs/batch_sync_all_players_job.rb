# frozen_string_literal: true

# Job to sync all active students' matches and ranks in batches
# Uses GraphQL batch queries to minimize API requests
class BatchSyncAllPlayersJob < ApplicationJob
  queue_as :default

  # Number of players to process per batch query
  BATCH_SIZE = 10

  retry_on StratzApi::RateLimitError, wait: 1.minute, attempts: 3

  def perform(since_days: 14)
    users = User.active_students
    total_users = users.count
    
    Rails.logger.info "Starting batch sync for #{total_users} users (last #{since_days} days)"
    
    processed = 0
    errors = []

    # Get all dota2 player IDs and build mapping
    users_by_steam_id = users.index_by { |u| u.dota2_player_id.to_s }
    player_ids = users_by_steam_id.keys.compact

    return if player_ids.empty?

    api = StratzApi.new

    # Process in batches - API now creates Match and MatchPlayer records directly
    begin
      api.batch_sync_players(player_ids, since_days: since_days, users_by_steam_id: users_by_steam_id)
      
      # Update ranks for all users
      player_ids.each do |player_id|
        user = users_by_steam_id[player_id]
        next unless user

        # Fetch fresh profile data for rank update
        profile = api.player_profile(player_id)
        if profile
          update_user_rank(user, profile)
          RankSnapshot.capture_for_user(user, profile)
        end

        processed += 1
        Rails.logger.info "Synced user #{user.id} (#{user.display_name})"
      end
      
      Rails.logger.info "Batch sync completed: #{processed}/#{total_users} users processed"
    rescue => e
      Rails.logger.error "Batch sync error: #{e.message}"
      errors << { error: e.message }
    end

    # After all matches are synced, calculate daily stats for yesterday
    CalculateDailyStatsJob.perform_later(Date.yesterday)
    
    {
      total_users: total_users,
      processed: processed,
      errors: errors.count
    }
  end

  private

  def update_user_rank(user, profile)
    new_rank = profile[:rank] || 0
    new_highest = [user.highest_rank, new_rank].max

    user.update!(
      current_rank: new_rank,
      highest_rank: new_highest,
      total_matches: profile[:match_count] || 0,
      total_wins: profile[:win_count] || 0,
      rank_updated_at: Time.current
    )
  rescue => e
    Rails.logger.error "Failed to update rank for user #{user.id}: #{e.message}"
  end
end
