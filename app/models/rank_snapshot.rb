# frozen_string_literal: true

class RankSnapshot < ApplicationRecord
  belongs_to :user

  validates :rank, presence: true, numericality: { only_integer: true }
  validates :captured_at, presence: true
  validates :match_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :win_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Rank tiers mapping based on Stratz rank values
  # Rank is typically a number where higher is better
  # Common ranges: Herald (1-5), Guardian (6-10), Crusader (11-15), 
  # Archon (16-20), Legend (21-25), Ancient (26-30), Divine (31-35), Immortal (36+)
  TIER_NAMES = {
    1 => "先锋",
    2 => "卫士", 
    3 => "中军",
    4 => "统帅",
    5 => "传奇",
    6 => "万古",
    7 => "超凡",
    8 => "冠绝"
  }.freeze

  # Calculate tier from rank value
  # Stratz rank is usually tier * 10 + stars - 1
  def tier
    return 0 if rank.nil? || rank <= 0
    (rank / 10) + 1
  end

  def tier_name
    TIER_NAMES[tier] || "未知"
  end

  # Calculate stars within tier (0-5)
  def stars
    return 0 if rank.nil? || rank <= 0
    (rank % 10) + 1
  end

  # Format rank as " tier_name stars"
  def display_rank
    return "未校准" if rank.nil? || rank <= 0
    "#{tier_name} #{stars}星"
  end

  # Calculate win rate
  def win_rate
    return 0 if match_count.zero?
    (win_count.to_f / match_count * 100).round(1)
  end

  # Class methods for statistics
  class << self
    # Capture current rank for a user
    def capture_for_user(user, profile_data = nil)
      profile_data ||= StratzApi.new.player_profile(user.dota2_player_id)
      return nil if profile_data.nil?

      create!(
        user: user,
        rank: profile_data[:rank] || 0,
        match_count: profile_data[:match_count] || 0,
        win_count: profile_data[:win_count] || 0,
        captured_at: Time.current
      )
    end

    # Get rank change between two snapshots
    def rank_change(user, from_time, to_time)
      from_snapshot = where(user: user).where("captured_at <= ?", from_time).order(captured_at: :desc).first
      to_snapshot = where(user: user).where("captured_at <= ?", to_time).order(captured_at: :desc).first

      return nil if from_snapshot.nil? || to_snapshot.nil?

      {
        rank_delta: to_snapshot.rank - from_snapshot.rank,
        matches_played: to_snapshot.match_count - from_snapshot.match_count,
        wins: to_snapshot.win_count - from_snapshot.win_count,
        from_rank: from_snapshot.rank,
        to_rank: to_snapshot.rank
      }
    end

    # Find users with highest rank improvement in a time period
    def top_improvers(since: 1.day.ago, limit: 10)
      # Get latest snapshot before 'since' and latest snapshot
      previous_snapshots = select("DISTINCT ON (user_id) user_id, rank as previous_rank, match_count as previous_matches, win_count as previous_wins")
                           .where("captured_at <= ?", since)
                           .order("user_id, captured_at DESC")
                           
      current_snapshots = select("DISTINCT ON (user_id) user_id, rank as current_rank, match_count as current_matches, win_count as current_wins")
                          .order("user_id, captured_at DESC")

      # Join and calculate improvements
      joins_sql = <<~SQL
        INNER JOIN (#{previous_snapshots.to_sql}) prev ON prev.user_id = rank_snapshots.user_id
        INNER JOIN (#{current_snapshots.to_sql}) curr ON curr.user_id = rank_snapshots.user_id
      SQL

      select("rank_snapshots.user_id, 
              (curr.current_rank - prev.previous_rank) as rank_improvement,
              (curr.current_matches - prev.previous_matches) as matches_played,
              (curr.current_wins - prev.previous_wins) as wins,
              prev.previous_rank,
              curr.current_rank")
        .joins(joins_sql)
        .where("curr.current_rank > prev.previous_rank")
        .order("rank_improvement DESC")
        .limit(limit)
    end
  end
end
