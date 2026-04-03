# frozen_string_literal: true

# Leaderboards controller for weekly rankings
class LeaderboardsController < ApplicationController
  def index
    # Redirect to home page (leaderboards are now displayed there)
    redirect_to root_path
  end

  def history
    # Get all available weeks for selection
    @available_weeks = WeeklyLeaderboard.distinct.pluck(:week_start).sort.reverse
  end

  def show
    # Show single week leaderboard details
    @week_start = parse_week_param || Date.current.beginning_of_week(:monday)
    @week_end = @week_start.end_of_week(:sunday)

    # Get summary stats
    @summary = WeeklyLeaderboard.week_summary(@week_start)

    # Get all leaderboards for this week
    load_leaderboards

    # For navigation
    @available_weeks = WeeklyLeaderboard.distinct.pluck(:week_start).sort.reverse
  end

  private

  def parse_week_param
    return nil if params[:week].blank?
    Date.parse(params[:week])
  rescue ArgumentError
    nil
  end

  def load_leaderboards
    # Top 3 metrics for the big cards
    @active_players = WeeklyLeaderboard.top_for(metric: "active_players", week_start: @week_start, limit: 1)
    @total_matches = WeeklyLeaderboard.top_for(metric: "matches_total", week_start: @week_start, limit: 1)
    @ranked_matches = WeeklyLeaderboard.top_for(metric: "matches_ranked", week_start: @week_start, limit: 1)

    # Player leaderboards
    @top_players_by_matches = WeeklyLeaderboard.top_for(metric: "player_matches", week_start: @week_start, limit: 10)
    @top_players_by_rank = WeeklyLeaderboard.top_for(metric: "rank_improvement", week_start: @week_start, limit: 10)
    @top_players_by_kda = WeeklyLeaderboard.top_for(metric: "kda_average", week_start: @week_start, limit: 10)
    @top_players_by_kills = WeeklyLeaderboard.top_for(metric: "kills_total", week_start: @week_start, limit: 10)
    @top_players_by_mvps = WeeklyLeaderboard.top_for(metric: "mvps_total", week_start: @week_start, limit: 10)

    # Classroom leaderboards
    @top_classrooms = WeeklyLeaderboard.top_for(metric: "classroom_matches", week_start: @week_start, limit: 10)
  end

  def metric_display_name(metric)
    names = {
      "active_players" => "活跃玩家",
      "matches_total" => "总场次",
      "matches_ranked" => "排位场次",
      "classroom_matches" => "班级场次榜",
      "player_matches" => "玩家场次榜",
      "rank_improvement" => "冲分榜",
      "kills_total" => "击杀榜",
      "kda_average" => "KDA榜",
      "mvps_total" => "MVP榜"
    }
    names[metric] || metric
  end
end
