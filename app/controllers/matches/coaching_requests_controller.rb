module Matches
  class CoachingRequestsController < ApplicationController
    before_action :require_authentication
    before_action :set_match
    before_action :set_coaching_request, only: [ :show, :claim, :complete, :reopen ]

    def show
      @events   = @coaching_request.events.includes(:operator).order(:created_at)
      @comments = @coaching_request.comments.includes(:user).order(:created_at)
      @comment  = Comment.new
    end

    def create
      unless current_user.student?
        return redirect_to match_coaching_request_path(@match), alert: "只有学员可以发起指导请求"
      end

      if @match.coaching_request.present?
        return redirect_to match_coaching_request_path(@match), alert: "该比赛已有指导请求"
      end

      if CoachingRequest.weekly_count_for(current_user) >= CoachingRequest::MAX_WEEKLY_COACHING_REQUESTS
        return redirect_to mine_matches_path, alert: "本周指导请求已达上限（#{CoachingRequest::MAX_WEEKLY_COACHING_REQUESTS} 次）"
      end

      @coaching_request = @match.build_coaching_request(student: current_user)
      if @coaching_request.save
        redirect_to match_coaching_request_path(@match), notice: "指导请求已提交"
      else
        redirect_to mine_matches_path, alert: "提交失败，请重试"
      end
    end

    def claim
      unless current_user.coach?
        return redirect_to match_coaching_request_path(@match), alert: "只有教练可以认领请求"
      end

      unless @coaching_request.requested?
        return redirect_to match_coaching_request_path(@match), alert: "该请求状态不允许认领"
      end

      @coaching_request.update!(coach: current_user)
      @coaching_request.transition_to!(:in_progress, operator: current_user)
      redirect_to match_coaching_request_path(@match), notice: "已认领，开始指导"
    end

    def complete
      unless current_user.student? || current_user.coach?
        return redirect_to match_coaching_request_path(@match), alert: "无权操作"
      end

      unless @coaching_request.in_progress?
        return redirect_to match_coaching_request_path(@match), alert: "该请求状态不允许完成"
      end

      @coaching_request.transition_to!(:completed, operator: current_user)
      redirect_to match_coaching_request_path(@match), notice: "指导已完成"
    end

    def reopen
      unless current_user.student?
        return redirect_to match_coaching_request_path(@match), alert: "只有学员可以重新开启"
      end

      unless @coaching_request.completed?
        return redirect_to match_coaching_request_path(@match), alert: "该请求状态不允许重新开启"
      end

      @coaching_request.transition_to!(:requested, operator: current_user)
      redirect_to match_coaching_request_path(@match), notice: "指导请求已重新开启"
    end

    private

      def set_match
        @match = Match.find(params[:match_id])
      end

      def set_coaching_request
        @coaching_request = @match.coaching_request
        redirect_to mine_matches_path, alert: "找不到指导请求" unless @coaching_request
      end
  end
end
