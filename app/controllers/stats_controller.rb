# frozen_string_literal: true

class StatsController < ApplicationController
  before_action :require_authentication, only: []
  
  # Daily stats dashboard
  def index
    @date = parse_date(params[:date]) || Date.yesterday
    
    @daily_stats = DailyStat
                     .for_date(@date)
                     .with_matches
                     .includes(user: [:classroom, :group])
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
               .includes(user: [:classroom, :group])
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

  # Classroom stats
  def classroom
    @classroom = Classroom.find(params[:id])
    @date = parse_date(params[:date]) || Date.yesterday
    
    @stats = DailyStat
               .for_date(@date)
               .joins(:user)
               .where(users: { classroom_id: @classroom.id })
               .with_matches
               .includes(user: :group)
               .order(matches_count: :desc)
    
    @classroom_stats = StatsService.classroom_stats(@classroom.id, @date)
  end

  # Group stats
  def group
    @group = Group.find(params[:id])
    @date = parse_date(params[:date]) || Date.yesterday
    
    @stats = DailyStat
               .for_date(@date)
               .joins(:user)
               .where(users: { group_id: @group.id })
               .with_matches
               .includes(user: :classroom)
               .order(matches_count: :desc)
    
    @group_stats = StatsService.group_stats(@group.id, @date)
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

  private

  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end
end
