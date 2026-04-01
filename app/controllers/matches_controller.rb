# frozen_string_literal: true

class MatchesController < ApplicationController
  before_action :require_authentication, only: [:mine, :update_match_player]
  before_action :set_match, only: [:show]
  before_action :set_match_player, only: [:update_match_player]

  def index
    @match_players = MatchPlayer.includes(match: [], user: [])
                                .order(created_at: :desc)
                                .page(params[:page])
                                .per(25)
  end

  def show
  end

  def mine
    @match_players = current_user.match_players
                                  .includes(match: [])
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(20)
  end

  def update_match_player
    if @match_player.update(match_player_params)
      redirect_to matches_path, notice: "对局已更新"
    else
      redirect_to matches_path, alert: "更新失败"
    end
  end

  private

  def set_match
    @match = Match.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to matches_path, alert: "对局未找到"
  end

  def set_match_player
    @match_player = current_user.match_players.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to matches_path, alert: "无权操作"
  end

  def match_player_params
    params.require(:match_player).permit(:lane_advantage, :award)
  end
end
