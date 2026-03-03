module Matches
  class CommentsController < ApplicationController
    before_action :require_authentication
    before_action :set_match_and_coaching_request

    def create
      @comment = @coaching_request.comments.build(comment_params.merge(user: current_user))
      if @comment.save
        redirect_to match_coaching_request_path(@match), notice: "复盘笔记已发布"
      else
        redirect_to match_coaching_request_path(@match), alert: "笔记内容不能为空"
      end
    end

    private

      def set_match_and_coaching_request
        @match = Match.find(params[:match_id])
        @coaching_request = @match.coaching_request
        redirect_to mine_matches_path, alert: "找不到指导请求" unless @coaching_request
      end

      def comment_params
        params.require(:comment).permit(:body)
      end
  end
end
