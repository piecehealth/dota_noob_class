# frozen_string_literal: true

# Service for generating various statistics and reports
class StatsService
  # Get daily leaderboard for a specific date
  # @param date [Date]
  # @param scope [Symbol] :all, :classroom, :group
  # @param scope_id [Integer] classroom_id or group_id
  def self.daily_leaderboard(date: Date.yesterday, scope: :all, scope_id: nil)
    stats = DailyStat.for_date(date).with_matches.includes(:user)
    
    case scope
    when :classroom
      stats = stats.joins(user: :classroom).where(users: { classroom_id: scope_id })
    when :group
      stats = stats.joins(user: :group).where(users: { group_id: scope_id })
    end
    
    stats.ordered
  end

  # Get top performers by various metrics
  # @param date [Date]
  # @param metric [Symbol] :matches_count, :wins_count, :win_rate, :avg_kda
  # @param limit [Integer]
  def self.top_performers(date: Date.yesterday, metric: :wins_count, limit: 10)
    DailyStat
      .for_date(date)
      .with_matches
      .includes(user: [:classroom, :group])
      .order(metric => :desc)
      .limit(limit)
  end

  # Get most improved players (by rank change)
  def self.most_improved(date: Date.yesterday, limit: 10)
    DailyStat
      .for_date(date)
      .where("rank_change > 0")
      .includes(user: [:classroom, :group])
      .order(rank_change: :desc)
      .limit(limit)
  end

  # Get overall statistics for a classroom
  def self.classroom_stats(classroom_id, date: Date.yesterday)
    user_ids = User.where(classroom_id: classroom_id).pluck(:id)
    
    DailyStat.aggregate_for_users(user_ids, date)
  end

  # Get overall statistics for a group
  def self.group_stats(group_id, date: Date.yesterday)
    user_ids = User.where(group_id: group_id).pluck(:id)
    
    DailyStat.aggregate_for_users(user_ids, date)
  end

  # Get global stats for a date
  def self.global_stats(date: Date.yesterday)
    DailyStat.aggregate_for_users(User.all.pluck(:id), date)
  end

  # Get rank distribution across all students
  def self.rank_distribution
    User
      .student
      .where("current_rank > 0")
      .group("(current_rank / 10) + 1")
      .count
      .transform_keys do |tier|
        tier_names = {
          1 => "先锋",
          2 => "卫士", 
          3 => "中军",
          4 => "统帅",
          5 => "传奇",
          6 => "万古",
          7 => "超凡",
          8 => "冠绝"
        }
        tier_names[tier.to_i] || "未知"
      end
  end

  # Get weekly activity report
  def self.weekly_report(end_date: Date.yesterday)
    start_date = end_date - 6.days
    
    matches = Match.where(played_at: start_date.beginning_of_day..end_date.end_of_day)
    
    daily_breakdown = (start_date..end_date).map do |date|
      day_matches = matches.where(played_at: date.all_day)
      
      {
        date: date,
        matches_count: day_matches.count,
        unique_players: day_matches.distinct.count(:user_id),
        wins: day_matches.where(won: true).count,
        losses: day_matches.where(won: false).count
      }
    end

    {
      period: "#{start_date} 至 #{end_date}",
      total_matches: matches.count,
      unique_players: matches.distinct.count(:user_id),
      daily_breakdown: daily_breakdown
    }
  end

  # Get player comparison stats
  def self.compare_players(user_ids, days: 7)
    start_date = days.days.ago.to_date
    
    User.where(id: user_ids).map do |user|
      matches = user.matches.where(played_at: start_date.beginning_of_day..Time.current)
      
      {
        user: user,
        matches_count: matches.count,
        wins: matches.where(won: true).count,
        losses: matches.where(won: false).count,
        win_rate: matches.count > 0 ? (matches.where(won: true).count.to_f / matches.count * 100).round(1) : 0,
        avg_kda: calculate_avg_kda(matches),
        current_rank: user.current_rank,
        rank_progress: calculate_rank_progress(user, days)
      }
    end
  end

  # Get star students (most improved over time period)
  def self.star_students(since: 7.days.ago, limit: 10)
    # Find users with significant rank improvement
    improvements = RankSnapshot
                     .select("user_id, 
                             MAX(rank) - MIN(rank) as rank_improvement,
                             MIN(captured_at) as first_snapshot,
                             MAX(captured_at) as last_snapshot")
                     .where("captured_at >= ?", since)
                     .group(:user_id)
                     .having("rank_improvement > 0")
                     .order("rank_improvement DESC")
                     .limit(limit)

    improvements.map do |imp|
      user = User.find(imp.user_id)
      {
        user: user,
        rank_improvement: imp.rank_improvement,
        days_tracked: ((imp.last_snapshot - imp.first_snapshot) / 1.day).round
      }
    end
  end

  private

  def self.calculate_avg_kda(matches)
    return 0 if matches.count.zero?
    
    total_kda = matches.sum do |m|
      m.deaths.zero? ? m.kills + m.assists : (m.kills + m.assists) / m.deaths.to_f
    end
    
    (total_kda / matches.count).round(2)
  end

  def self.calculate_rank_progress(user, days)
    old_snapshot = user.rank_snapshots.where("captured_at <= ?", days.days.ago).order(captured_at: :desc).first
    latest_snapshot = user.rank_snapshots.order(captured_at: :desc).first
    
    return { change: 0, old_rank: nil, new_rank: nil } if old_snapshot.nil? || latest_snapshot.nil?
    
    {
      change: latest_snapshot.rank - old_snapshot.rank,
      old_rank: old_snapshot.rank,
      new_rank: latest_snapshot.rank
    }
  end
end
