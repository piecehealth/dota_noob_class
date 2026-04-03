# frozen_string_literal: true

class MatchesController < ApplicationController
  before_action :require_authentication, only: [ :mine, :update_match_player ]
  before_action :set_match, only: [ :show ]
  before_action :set_match_player, only: [ :update_match_player ]
  before_action :load_filter_options, only: [ :index ]

  def index
    @match_players = MatchPlayer.includes(match: [], user: [ :classroom, :group ])
                                .joins(:match)
                                .order("matches.played_at DESC")

    # Apply filters
    if params[:classroom_id].present?
      @match_players = @match_players.joins(user: :classroom)
                                      .where(users: { classroom_id: params[:classroom_id] })
    end

    if params[:group_id].present?
      @match_players = @match_players.joins(user: :group)
                                      .where(users: { group_id: params[:group_id] })
    end

    @match_players = @match_players.page(params[:page]).per(25)
  end

  def show
  end

  def mine
    @matches = current_user.match_players
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

  def load_filter_options
    @classrooms = Classroom.order(:number)

    if params[:classroom_id].present?
      @groups = Group.where(classroom_id: params[:classroom_id]).order(:number)
    else
      @groups = []
    end
  end
end
