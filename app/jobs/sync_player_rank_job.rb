# frozen_string_literal: true

# Job to sync rank info for a single player from Stratz API
class SyncPlayerRankJob < ApplicationJob
  queue_as :default

  retry_on StratzApi::RateLimitError, wait: :exponentially_longer, attempts: 3
  
  discard_on StratzApi::Error do |job, error|
    Rails.logger.error "Failed to sync rank for user #{job.arguments.first}: #{error.message}"
  end

  def perform(user_id)
    user = User.find(user_id)
    return unless user.student? && user.dota2_player_id

    result = user.update_rank_info!
    
    if result
      Rails.logger.info "Updated rank for user #{user_id}: #{result[:rank]} (highest: #{result[:highest_rank]})"
    end
    
    result
  end
end
