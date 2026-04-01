# frozen_string_literal: true

# Job to sync matches for a single player from Stratz API
class SyncPlayerMatchesJob < ApplicationJob
  queue_as :default

  # Retry on rate limit with exponential backoff
  retry_on StratzApi::RateLimitError, wait: :exponentially_longer, attempts: 3
  
  # Discard on other API errors after logging
  discard_on StratzApi::Error do |job, error|
    Rails.logger.error "Failed to sync matches for user #{job.arguments.first}: #{error.message}"
  end

  def perform(user_id, since_days: 14)
    user = User.find(user_id)
    return unless user.student? && user.dota2_player_id

    count = user.sync_matches(since_days: since_days)
    
    Rails.logger.info "Synced #{count} matches for user #{user_id} (#{user.display_name})"
    
    # Update daily stats for today
    DailyStat.calculate_for_user(user, Date.current)
    
    count
  rescue User::SyncError => e
    Rails.logger.error "Sync error for user #{user_id}: #{e.message}"
    0
  end
end
