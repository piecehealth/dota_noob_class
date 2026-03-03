class MatchesController < ApplicationController
  before_action :require_authentication

  def mine
    @matches = current_user.matches.order(played_at: :desc).page(params[:page]).per(20)
  end
end
