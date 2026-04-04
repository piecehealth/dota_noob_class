# frozen_string_literal: true

class StatsController < ApplicationController
  before_action :require_authentication, only: []

  # Daily stats dashboard
  def index
    @date = parse_date(params[:date]) || Date.yesterday

    @daily_stats = DailyStat
                     .for_date(@date)
                     .with_matches
                     .includes(user: [ :classroom, :group ])
                     .order(matches_count: :desc)
                     .limit(50)

    @global_stats = StatsService.global_stats(date: @date)
    @rank_distribution = StatsService.rank_distribution
  end

  # Daily leaderboard
  def daily
    @date = parse_date(params[:date]) || Date.yesterday

    @stats = DailyStat
               .for_date(@date)
               .with_matches
               .includes(user: [ :classroom, :group ])
               .order(matches_count: :desc)
  end

  # Top performers
  def top_performers
    @date = parse_date(params[:date]) || Date.yesterday
    @metric = params[:metric]&.to_sym || :wins_count
    @allowed_metrics = %i[matches_count wins_count avg_kda rank_change]

    @metric = :wins_count unless @allowed_metrics.include?(@metric)

    @stats = StatsService.top_performers(date: @date, metric: @metric, limit: 20)
  end

  # Most improved (star students)
  def stars
    @since = params[:since] ? params[:since].to_i.days.ago : 7.days.ago
    @star_students = StatsService.star_students(since: @since, limit: 20)
  end

  # Classroom stats - weekly view
  def classroom
    @classroom = Classroom.find(params[:id])
    @week_start = params[:week] ? Date.parse(params[:week]) : Date.current.beginning_of_week(:monday)
    @week_end = @week_start.end_of_week(:sunday)

    # Get all users in classroom
    @users = User.where(classroom_id: @classroom.id).includes(:group).order(:display_name)

    # Calculate weekly stats for each user
    @user_stats = calculate_user_weekly_stats(@users, @week_start, @week_end)

    # Group stats (sum by group)
    @group_stats = calculate_group_weekly_stats(@classroom, @week_start, @week_end)

    # Total stats
    @total_stats = calculate_total_stats(@user_stats)
  end

  # Group stats - weekly view
  def group
    @group = Group.find(params[:id])
    @classroom = @group.classroom
    @week_start = params[:week] ? Date.parse(params[:week]) : Date.current.beginning_of_week(:monday)
    @week_end = @week_start.end_of_week(:sunday)

    # Get all users in group
    @users = User.where(group_id: @group.id).order(:display_name)

    # Calculate weekly stats for each user
    @user_stats = calculate_user_weekly_stats(@users, @week_start, @week_end)

    # Total stats
    @total_stats = calculate_total_stats(@user_stats)
  end

  # Weekly report
  def weekly
    @end_date = parse_date(params[:end_date]) || Date.yesterday
    @report = StatsService.weekly_report(end_date: @end_date)
  end

  # Rank distribution
  def ranks
    @rank_distribution = StatsService.rank_distribution

    # Get users by rank tier
    @users_by_tier = User
                       .student
                       .where("current_rank > 0")
                       .includes(:classroom, :group)
                       .order(current_rank: :desc)
                       .group_by { |u| (u.current_rank / 10) + 1 }
  end

  # Player comparison
  def compare
    @user_ids = params[:user_ids]&.map(&:to_i)&.compact || []
    @days = (params[:days] || 7).to_i

    if @user_ids.size >= 2
      @comparisons = StatsService.compare_players(@user_ids, days: @days)
    end

    # Available users for selection
    @available_users = User.active_students.includes(:classroom, :group).order(:display_name)
  end

  # All students stats with filters and sorting (handled by frontend)
  def students
    @classrooms = Classroom.order(:number)
    @groups = Group.includes(:classroom).order(:classroom_id, :number)

    # Week selection (default to current week)
    @week_start = params[:week] ? Date.parse(params[:week]) : Date.current.beginning_of_week(:monday)
    @week_end = @week_start.end_of_week(:sunday)

    # Get available weeks for navigation
    @available_weeks = Match.where.not(played_at: nil)
                            .select("DATE(played_at, 'weekday 0', '-6 days') as week_start")
                            .distinct
                            .order("week_start DESC")
                            .map { |m| Date.parse(m.week_start) rescue nil }
                            .compact
                            .uniq

    # Add current week if not present
    current_week = Date.current.beginning_of_week(:monday)
    @available_weeks.unshift(current_week) unless @available_weeks.include?(current_week)

    # Calculate stats directly (N+1 already optimized)
    @students = calculate_students_stats(@week_start, @week_end)
  end

  private

  def calculate_students_stats(week_start = nil, week_end = nil)
    # Preload all data in batches to avoid N+1
    user_ids = User.student.pluck(:id)

    # Build base query
    base_query = MatchPlayer.where(user_id: user_ids)

    # Add date filter if provided
    if week_start && week_end
      base_query = base_query.joins(:match).where(matches: { played_at: week_start.beginning_of_day..week_end.end_of_day })
    end

    # Batch fetch match player stats
    match_stats = base_query
      .group(:user_id)
      .select(
        :user_id,
        "COUNT(*) as total_matches",
        "SUM(CASE WHEN won = 1 THEN 1 ELSE 0 END) as wins",
        "SUM(CASE WHEN won = 0 THEN 1 ELSE 0 END) as losses",
        "SUM(kills) as kills",
        "SUM(deaths) as deaths",
        "SUM(assists) as assists"
      )
      .index_by(&:user_id)

    # Fetch users with classroom/group
    users = User.student.includes(:classroom, :group).to_a

    users.map do |user|
      stats = match_stats[user.id]

      total_matches = stats ? stats.total_matches.to_i : 0
      wins = stats ? stats.wins.to_i : 0
      losses = stats ? stats.losses.to_i : 0
      kills = stats ? stats.kills.to_i : 0
      deaths = stats ? stats.deaths.to_i : 0
      assists = stats ? stats.assists.to_i : 0

      win_rate = total_matches > 0 ? (wins.to_f / total_matches * 100).round(1) : 0
      kda = deaths > 0 ? ((kills + assists) / deaths.to_f).round(2) : (kills + assists)

      {
        id: user.id,
        display_name: user.display_name,
        classroom_id: user.classroom_id,
        classroom_number: user.classroom&.number,
        group_id: user.group_id,
        group_number: user.group&.number,
        dota2_player_id: user.dota2_player_id,
        current_rank: user.current_rank,
        highest_rank: user.highest_rank,
        total_matches: total_matches,
        wins: wins,
        losses: losses,
        win_rate: win_rate,
        kills: kills,
        deaths: deaths,
        assists: assists,
        kda: kda
      }
    end.sort_by { |s| -s[:total_matches] }
  end

  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

  # Calculate weekly stats for users
  def calculate_user_weekly_stats(users, week_start, week_end)
    users.map do |user|
      match_players = MatchPlayer.joins(:match)
                                  .where(user: user)
                                  .where(matches: { played_at: week_start.beginning_of_day..week_end.end_of_day })

      total_matches = match_players.count
      wins = match_players.where(won: true).count
      losses = match_players.where(won: false).count

      kills = match_players.sum(:kills)
      deaths = match_players.sum(:deaths)
      assists = match_players.sum(:assists)

      win_rate = total_matches > 0 ? (wins.to_f / total_matches * 100).round(1) : 0
      kda = deaths > 0 ? ((kills + assists) / deaths.to_f).round(2) : (kills + assists)

      {
        user: user,
        matches: total_matches,
        wins: wins,
        losses: losses,
        win_rate: win_rate,
        kills: kills,
        deaths: deaths,
        assists: assists,
        kda: kda
      }
    end.sort_by { |s| -s[:matches] }
  end

  # Calculate stats grouped by group
  def calculate_group_weekly_stats(classroom, week_start, week_end)
    classroom.groups.map do |group|
      user_ids = User.where(group_id: group.id).pluck(:id)
      match_players = MatchPlayer.joins(:match)
                                  .where(user_id: user_ids)
                                  .where(matches: { played_at: week_start.beginning_of_day..week_end.end_of_day })

      total_matches = match_players.count
      wins = match_players.where(won: true).count
      losses = match_players.where(won: false).count

      {
        group: group,
        matches: total_matches,
        wins: wins,
        losses: losses,
        win_rate: total_matches > 0 ? (wins.to_f / total_matches * 100).round(1) : 0,
        members: user_ids.count
      }
    end.sort_by { |s| -s[:matches] }
  end

  # Calculate total stats
  def calculate_total_stats(user_stats)
    total_matches = user_stats.sum { |s| s[:matches] }
    total_wins = user_stats.sum { |s| s[:wins] }
    total_losses = user_stats.sum { |s| s[:losses] }

    {
      matches: total_matches,
      wins: total_wins,
      losses: total_losses,
      participants: user_stats.count { |s| s[:matches] > 0 }
    }
  end
end
