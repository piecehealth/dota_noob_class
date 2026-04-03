# frozen_string_literal: true

class DailyStat < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :matches_count, numericality: { greater_than_or_equal_to: 0 }
  validates :wins_count, numericality: { greater_than_or_equal_to: 0 }
  validates :losses_count, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :date }

  # Scopes
  scope :for_date, ->(date) { where(date: date) }
  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :with_matches, -> { where("matches_count > 0") }
  scope :ordered, -> { order(date: :desc, matches_count: :desc) }

  # Calculate KDA
  def kda
    return 0 if deaths.zero?
    ((kills + assists) / deaths.to_f).round(2)
  end

  def win_rate
    return 0 if matches_count.zero?
    (wins_count.to_f / matches_count * 100).round(1)
  end

  def avg_match_duration
    return 0 if matches_count.zero?
    total_duration / matches_count
  end

  def avg_match_duration_formatted
    minutes = avg_match_duration / 60
    seconds = avg_match_duration % 60
    "#{minutes}分#{seconds}秒"
  end

  # Class methods for aggregation
  class << self
    # Calculate stats for a user on a specific date
    def calculate_for_user(user, date)
      start_of_day = date.beginning_of_day
      end_of_day = date.end_of_day

      # Get match_players for this user on this date
      match_players = user.match_players
                          .joins(:match)
                          .where(matches: { played_at: start_of_day..end_of_day })

      return nil if match_players.empty?

      wins = match_players.where(won: true).count
      losses = match_players.where(won: false).count

      kills = match_players.sum(:kills)
      deaths = match_players.sum(:deaths)
      assists = match_players.sum(:assists)

      total_duration = match_players.sum("matches.duration")

      avg_kda = if deaths > 0
        ((kills + assists) / deaths.to_f).round(2)
      else
        kills + assists
      end

      # Get end of day rank from snapshot
      rank_snapshot = user.rank_snapshots.where("captured_at <= ?", end_of_day).order(captured_at: :desc).first
      end_of_day_rank = rank_snapshot&.rank

      # Calculate rank change from beginning of day
      start_rank_snapshot = user.rank_snapshots.where("captured_at <= ?", start_of_day).order(captured_at: :desc).first
      rank_change = if start_rank_snapshot && rank_snapshot
        rank_snapshot.rank - start_rank_snapshot.rank
      else
        0
      end

      find_or_initialize_by(user: user, date: date).tap do |stat|
        stat.assign_attributes(
          matches_count: match_players.count,
          wins_count: wins,
          losses_count: losses,
          total_kills: kills,
          total_deaths: deaths,
          total_assists: assists,
          avg_kda: avg_kda,
          total_duration: total_duration,
          end_of_day_rank: end_of_day_rank,
          rank_change: rank_change
        )
        stat.save!
      end
    end

    # Aggregate stats for a group/classroom
    def aggregate_for_users(user_ids, date)
      stats = where(user_id: user_ids, date: date)

      {
        total_matches: stats.sum(:matches_count),
        total_wins: stats.sum(:wins_count),
        total_losses: stats.sum(:losses_count),
        total_kills: stats.sum(:total_kills),
        total_deaths: stats.sum(:total_deaths),
        total_assists: stats.sum(:total_assists),
        avg_win_rate: stats.average(:wins_count).to_f,
        avg_kda: stats.average(:avg_kda).to_f,
        participants: stats.count
      }
    end

    # Top performers for a date
    def top_performers(date:, by: :matches_count, limit: 10)
      for_date(date)
        .with_matches
        .includes(:user)
        .order(by => :desc)
        .limit(limit)
    end

    # Most improved players (by rank_change)
    def most_improved(date:, limit: 10)
      for_date(date)
        .where("rank_change > 0")
        .includes(:user)
        .order(rank_change: :desc)
        .limit(limit)
    end
  end
end
