class MatchesController < ApplicationController
  before_action :require_authentication

  def mine
    @matches = current_user.matches.includes(:coaching_request).order(played_at: :desc).page(params[:page]).per(20)
    @weekly_limit_reached = CoachingRequest.weekly_count_for(current_user) >= CoachingRequest::MAX_WEEKLY_COACHING_REQUESTS
  end
end
