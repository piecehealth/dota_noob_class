class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :matches ]

  def show
  end

  def matches
    @student = @user
    @matches = @student.match_players
                       .includes(:match)
                       .order("matches.played_at DESC")
                       .page(params[:page])
                       .per(20)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
