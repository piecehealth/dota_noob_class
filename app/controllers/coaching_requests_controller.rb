class CoachingRequestsController < ApplicationController
  before_action :require_authentication
  before_action :require_coach

  def index
    classroom = current_user.classroom
    @coaching_requests = CoachingRequest
      .joins(student: :group)
      .where(groups: { classroom_id: classroom.id })
      .where(status: [ :requested, :in_progress ])
      .includes(:match, :student, student: :group)
      .sort_by { |cr| cr.student.group_id == current_user.group_id ? 0 : 1 }
  end

  private

    def require_coach
      redirect_to root_path, alert: "无权访问" unless current_user.coach?
    end
end
