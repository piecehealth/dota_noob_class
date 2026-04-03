# frozen_string_literal: true

# Stores weekly leaderboard rankings for various metrics
class WeeklyLeaderboard < ApplicationRecord
  belongs_to :entity, polymorphic: true, optional: true
  belongs_to :classroom, optional: true
  belongs_to :group, optional: true

  # Metric types
  METRICS = %w[
    matches_total
    matches_ranked
    active_players
    classroom_matches
    player_matches
    rank_improvement
    kills_total
    assists_total
    kda_average
    win_rate
    wins_total
    mvps_total
  ].freeze

  validates :metric_type, presence: true, inclusion: { in: METRICS }
  validates :entity_type, presence: true
  validates :week_start, presence: true
  validates :week_end, presence: true
  validates :value, presence: true, numericality: { only_integer: true }
  validates :rank, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Scopes
  scope :for_week, ->(week_start) { where(week_start: week_start) }
  scope :for_week_range, ->(start_date, end_date) { where(week_start: start_date..end_date) }
  scope :by_metric, ->(metric) { where(metric_type: metric) }
  scope :by_entity_type, ->(type) { where(entity_type: type) }
  scope :top, ->(limit = 10) { where(rank: 1..limit).order(:rank) }
  scope :ordered, -> { order(:rank) }

  # Class methods for querying
  class << self
    # Get top N for a specific metric and week
    def top_for(metric:, week_start:, limit: 10)
      by_metric(metric).for_week(week_start).top(limit)
    end

    # Get summary stats for a week (big numbers at top of page)
    def week_summary(week_start)
      {
        active_players: by_metric("active_players").for_week(week_start).first&.value || 0,
        matches_total: by_metric("matches_total").for_week(week_start).first&.value || 0,
        matches_ranked: by_metric("matches_ranked").for_week(week_start).first&.value || 0
      }
    end

    # Calculate all leaderboards for a week
    def calculate_for_week!(week_start = Date.current.beginning_of_week(:monday))
      week_end = week_start.end_of_week(:sunday)

      # Clear existing data for this week
      where(week_start: week_start).destroy_all

      # Calculate all metrics
      calculate_active_players!(week_start, week_end)
      calculate_match_counts!(week_start, week_end)
      calculate_classroom_leaderboards!(week_start, week_end)
      calculate_player_leaderboards!(week_start, week_end)
      calculate_rank_improvements!(week_start, week_end)
      calculate_kda_leaderboards!(week_start, week_end)
      calculate_mvp_leaderboards!(week_start, week_end)

      Rails.logger.info "Weekly leaderboards calculated for #{week_start} to #{week_end}"
    end

    private

    # 1. 本周有游玩记录的玩家数
    def calculate_active_players!(week_start, week_end)
      active_count = MatchPlayer.joins(:match)
                                .where(matches: { played_at: week_start.beginning_of_day..week_end.end_of_day })
                                .distinct
                                .count(:user_id)

      create!(
        week_start: week_start,
        week_end: week_end,
        metric_type: "active_players",
        entity_type: "System",
        entity_id: 0,
        entity_name: "本周活跃玩家",
        value: active_count,
        rank: 1
      )
    end

    # 2. 本周打游戏的总场次 + 排位场次
    def calculate_match_counts!(week_start, week_end)
      matches = Match.where(played_at: week_start.beginning_of_day..week_end.end_of_day)
      total_matches = matches.count
      ranked_matches = matches.where(lobby_type: 7).count

      create!(
        week_start: week_start,
        week_end: week_end,
        metric_type: "matches_total",
        entity_type: "System",
        entity_id: 0,
        entity_name: "本周总场次",
        value: total_matches,
        rank: 1
      )

      create!(
        week_start: week_start,
        week_end: week_end,
        metric_type: "matches_ranked",
        entity_type: "System",
        entity_id: 0,
        entity_name: "本周排位场次",
        value: ranked_matches,
        rank: 1
      )
    end

    # 3. 游戏场数最多的班级前十
    def calculate_classroom_leaderboards!(week_start, week_end)
      classroom_stats = MatchPlayer.joins(:match, user: :classroom)
                                   .where.not(users: { classroom_id: nil })
                                   .where(matches: { played_at: week_start.beginning_of_day..week_end.end_of_day })
                                   .group("classrooms.id", "classrooms.name")
                                   .count("match_players.id")

      classroom_stats.sort_by { |_, count| -count }.first(10).each_with_index do |((classroom_id, classroom_name), count), index|
        create!(
          week_start: week_start,
          week_end: week_end,
          metric_type: "classroom_matches",
          entity_type: "Classroom",
          entity_id: classroom_id,
          entity_name: classroom_name,
          value: count,
          rank: index + 1,
          classroom_id: classroom_id
        )
      end
    end

    # 4. 游戏场数最多的玩家前十
    def calculate_player_leaderboards!(week_start, week_end)
      player_stats = MatchPlayer.joins(:match, :user)
                                .where(matches: { played_at: week_start.beginning_of_day..week_end.end_of_day })
                                .group("users.id", "users.display_name", "users.classroom_id", "users.group_id")
                                .count("match_players.id")

      player_stats.sort_by { |_, count| -count }.first(10).each_with_index do |((user_id, display_name, classroom_id, group_id), count), index|
        create!(
          week_start: week_start,
          week_end: week_end,
          metric_type: "player_matches",
          entity_type: "User",
          entity_id: user_id,
          entity_name: display_name,
          value: count,
          rank: index + 1,
          classroom_id: classroom_id,
          group_id: group_id
        )
      end
    end

    # 5. 天梯等级提升最多的玩家前十（准确计算）
    # 不是简单减法，而是计算段位等级变化（如 统帅3星 -> 传奇1星 = 提升3级）
    def calculate_rank_improvements!(week_start, week_end)
      improvements = []

      User.student.where.not(dota2_player_id: nil).find_each do |user|
        # 获取本周开始和结束时的段位快照
        start_snapshot = user.rank_snapshots
                              .where("captured_at >= ?", week_start.beginning_of_day)
                              .where("captured_at <= ?", [ week_start.end_of_day, Time.current ].min)
                              .order(:captured_at)
                              .first

        end_snapshot = user.rank_snapshots
                            .where("captured_at >= ?", week_start.beginning_of_day)
                            .where("captured_at <= ?", [ week_end.end_of_day, Time.current ].min)
                            .order(captured_at: :desc)
                            .first

        # 如果没有本周快照，尝试找最近的历史记录
        start_snapshot ||= user.rank_snapshots
                                .where("captured_at < ?", week_start.beginning_of_day)
                                .order(captured_at: :desc)
                                .first

        end_snapshot ||= user.rank_snapshots
                              .where("captured_at < ?", week_start.beginning_of_day)
                              .order(captured_at: :desc)
                              .first

        next if start_snapshot.nil? || end_snapshot.nil?
        next if end_snapshot.captured_at <= start_snapshot.captured_at

        # 计算段位等级变化
        improvement = calculate_rank_level_change(start_snapshot.rank, end_snapshot.rank)
        next if improvement <= 0

        improvements << {
          user: user,
          improvement: improvement,
          start_rank: start_snapshot.rank,
          end_rank: end_snapshot.rank
        }
      end

      # 排序并取前10
      improvements.sort_by { |i| -i[:improvement] }.first(10).each_with_index do |data, index|
        create!(
          week_start: week_start,
          week_end: week_end,
          metric_type: "rank_improvement",
          entity_type: "User",
          entity_id: data[:user].id,
          entity_name: data[:user].display_name,
          value: data[:improvement],
          rank: index + 1,
          classroom_id: data[:user].classroom_id,
          group_id: data[:user].group_id,
          details: {
            start_rank: data[:start_rank],
            end_rank: data[:end_rank],
            start_display: rank_to_display(data[:start_rank]),
            end_display: rank_to_display(data[:end_rank])
          }
        )
      end
    end

    # 6. KDA 排行榜
    def calculate_kda_leaderboards!(week_start, week_end)
      # 使用原始查询获取KDA数据，避免与模型方法冲突
      start_time = week_start.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
      end_time = week_end.end_of_day.strftime("%Y-%m-%d %H:%M:%S")

      kda_results = MatchPlayer.connection.select_all(<<-SQL.squish)
        SELECT#{' '}
          users.id as user_id,
          users.display_name as display_name,
          users.classroom_id as classroom_id,
          users.group_id as group_id,
          SUM(match_players.kills) as total_kills,
          SUM(match_players.deaths) as total_deaths,
          SUM(match_players.assists) as total_assists,
          COUNT(*) as match_count,
          CAST(SUM(match_players.kills) + SUM(match_players.assists) AS FLOAT) / NULLIF(SUM(match_players.deaths), 0) as kda
        FROM match_players
        INNER JOIN matches ON matches.id = match_players.match_id
        INNER JOIN users ON users.id = match_players.user_id
        WHERE matches.played_at BETWEEN '#{start_time}' AND '#{end_time}'
          AND match_players.deaths > 0
        GROUP BY users.id, users.display_name, users.classroom_id, users.group_id
        HAVING COUNT(*) >= 3
      SQL

      # 转换为 hash 便于使用
      player_kda = kda_results.map do |r|
        {
          user_id: r["user_id"],
          display_name: r["display_name"],
          classroom_id: r["classroom_id"],
          group_id: r["group_id"],
          total_kills: r["total_kills"],
          total_deaths: r["total_deaths"],
          total_assists: r["total_assists"],
          match_count: r["match_count"],
          kda: r["kda"].to_f
        }
      end

      # 场均KDA榜
      player_kda.sort_by { |p| -(p[:kda] || 0) }.first(10).each_with_index do |player, index|
        kda_value = player[:kda] || 0
        create!(
          week_start: week_start,
          week_end: week_end,
          metric_type: "kda_average",
          entity_type: "User",
          entity_id: player[:user_id],
          entity_name: player[:display_name],
          value: (kda_value * 100).to_i, # 存储为整数 (3.45 -> 345)
          rank: index + 1,
          classroom_id: player[:classroom_id],
          group_id: player[:group_id],
          details: {
            kills: player[:total_kills],
            deaths: player[:total_deaths],
            assists: player[:total_assists],
            match_count: player[:match_count],
            kda_formatted: "%.2f" % kda_value
          }
        )
      end

      # 总击杀榜
      player_kills = MatchPlayer.joins(:match, :user)
                                .where(matches: { played_at: week_start.beginning_of_day..week_end.end_of_day })
                                .group("users.id", "users.display_name", "users.classroom_id", "users.group_id")
                                .sum("match_players.kills")

      player_kills.sort_by { |_, kills| -kills }.first(10).each_with_index do |((user_id, display_name, classroom_id, group_id), kills), index|
        create!(
          week_start: week_start,
          week_end: week_end,
          metric_type: "kills_total",
          entity_type: "User",
          entity_id: user_id,
          entity_name: display_name,
          value: kills,
          rank: index + 1,
          classroom_id: classroom_id,
          group_id: group_id
        )
      end
    end

    # 7. MVP 排行榜
    def calculate_mvp_leaderboards!(week_start, week_end)
      mvp_stats = MatchPlayer.joins(:match, :user)
                             .where(matches: { played_at: week_start.beginning_of_day..week_end.end_of_day })
                             .where(award: [ "MVP", "TOP_CORE", "TOP_SUPPORT" ])
                             .group("users.id", "users.display_name", "users.classroom_id", "users.group_id")
                             .count("match_players.id")

      mvp_stats.sort_by { |_, count| -count }.first(10).each_with_index do |((user_id, display_name, classroom_id, group_id), count), index|
        create!(
          week_start: week_start,
          week_end: week_end,
          metric_type: "mvps_total",
          entity_type: "User",
          entity_id: user_id,
          entity_name: display_name,
          value: count,
          rank: index + 1,
          classroom_id: classroom_id,
          group_id: group_id
        )
      end
    end

    # 辅助方法：计算段位等级变化
    # rank 是 0-159 的数字，每10级一个大段位，每级1星
    # 0-9: 先锋1-5星, 10-19: 卫士1-5星, ...
    # 段位提升 = (结束时的总等级 - 开始时的总等级)
    # 总等级 = 大段位 * 5 + 星级 (0-7 * 5 + 0-4)
    def calculate_rank_level_change(start_rank, end_rank)
      return 0 if start_rank.nil? || end_rank.nil?

      # 将 rank 转换为段位等级
      # rank 0-159 对应先锋1星到冠绝5星
      # 每个大段位有10级（rank值），对应5个星级
      start_level = rank_to_level(start_rank)
      end_level = rank_to_level(end_rank)

      end_level - start_level
    end

    # 将 rank 转换为总等级数 (0-39，共8个大段*5星)
    def rank_to_level(rank)
      return 0 if rank.nil? || rank < 0

      # 大段位 (0-7)
      tier = rank / 10
      # 星级 (0-9 的 rank 对应 0-4 星，但每2个rank对应1星)
      # 实际上 rank % 10 是 0-9，其中 0-1=1星, 2-3=2星, 4-5=3星, 6-7=4星, 8-9=5星
      stars = (rank % 10) / 2

      tier * 5 + stars
    end

    # 将 rank 转换为可读格式
    def rank_to_display(rank)
      return "未校准" if rank.nil? || rank < 0

      tier_names = %w[先锋 卫士 中军 统帅 传奇 万古 超凡 冠绝]
      tier = [ rank / 10, 7 ].min
      stars = (rank % 10) / 2 + 1

      "#{tier_names[tier]} #{stars}星"
    end
  end
end
