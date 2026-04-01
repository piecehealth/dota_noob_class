# frozen_string_literal: true

# Job to calculate daily statistics for all users
class CalculateDailyStatsJob < ApplicationJob
  queue_as :default

  def perform(date = Date.yesterday)
    # Calculate stats for all users who played on the given date
    user_ids = Match.where(played_at: date.all_day).distinct.pluck(:user_id)
    
    Rails.logger.info "Calculating daily stats for #{user_ids.count} users on #{date}"
    
    calculated = 0
    errors = 0

    User.where(id: user_ids).find_each do |user|
      begin
        DailyStat.calculate_for_user(user, date)
        calculated += 1
      rescue => e
        Rails.logger.error "Error calculating daily stats for user #{user.id}: #{e.message}"
        errors += 1
      end
    end

    Rails.logger.info "Daily stats calculated: #{calculated} users, #{errors} errors"
    
    {
      date: date,
      calculated: calculated,
      errors: errors
    }
  end
end
