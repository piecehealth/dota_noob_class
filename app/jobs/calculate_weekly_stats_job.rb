# frozen_string_literal: true

# Job to calculate weekly leaderboards and statistics
# Runs at 5am and 5pm daily to update current week's rankings
class CalculateWeeklyStatsJob < ApplicationJob
  queue_as :default

  def perform(week_start = nil)
    # Default to current week (starting Monday)
    week_start ||= Date.current.beginning_of_week(:monday)

    Rails.logger.info "Calculating weekly stats for week of #{week_start}"

    # Calculate all leaderboards
    WeeklyLeaderboard.calculate_for_week!(week_start)

    # Also calculate previous week if it's complete
    previous_week = week_start - 7.days
    if previous_week.end_of_week(:sunday) < Date.current.beginning_of_day
      Rails.logger.info "Also calculating previous week: #{previous_week}"
      WeeklyLeaderboard.calculate_for_week!(previous_week)
    end

    Rails.logger.info "Weekly stats calculation completed"
  end
end
