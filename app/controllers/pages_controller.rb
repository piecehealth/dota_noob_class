class PagesController < ApplicationController
  def home
    # 获取本周排行榜数据
    @week_start = Date.current.beginning_of_week(:monday)
    @week_end = @week_start.end_of_week(:sunday)

    @summary = WeeklyLeaderboard.week_summary(@week_start)

    # 各排行榜
    @top_players_by_matches = WeeklyLeaderboard.top_for(metric: "player_matches", week_start: @week_start, limit: 10)
    @top_players_by_rank = WeeklyLeaderboard.top_for(metric: "rank_improvement", week_start: @week_start, limit: 10)
    @top_players_by_kda = WeeklyLeaderboard.top_for(metric: "kda_average", week_start: @week_start, limit: 10)
    @top_players_by_kills = WeeklyLeaderboard.top_for(metric: "kills_total", week_start: @week_start, limit: 10)
    @top_players_by_mvps = WeeklyLeaderboard.top_for(metric: "mvps_total", week_start: @week_start, limit: 10)
    @top_classrooms = WeeklyLeaderboard.top_for(metric: "classroom_matches", week_start: @week_start, limit: 10)

    # 往期周列表
    @available_weeks = WeeklyLeaderboard.distinct.pluck(:week_start).sort.reverse
  end
end
