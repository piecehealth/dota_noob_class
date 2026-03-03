class UsersController < ApplicationController
  before_action :require_authentication

  def matches
    @student = User.find(params[:id])
    authorize_student_view!
    @matches = @student.matches.order(played_at: :desc).page(params[:page]).per(20)
  end

  private

    def authorize_student_view!
      return if current_user.admin? || current_user.coach? || current_user.assistant?
      return if current_user.id == @student.id

      redirect_to root_path, alert: "无权限"
    end
end
