class CoachingRequestsController < ApplicationController
  before_action :require_authentication

  def index
    require_coach
    classroom = current_user.classroom
    @coaching_requests = CoachingRequest
      .joins(student: :group)
      .where(groups: { classroom_id: classroom.id })
      .where(status: [ :requested, :in_progress ])
      .includes(:match, :student, student: :group)
      .sort_by { |cr| cr.student.group_id == current_user.group_id ? 0 : 1 }
  end

  def mine
    require_student
    @coaching_requests = current_user.coaching_requests_as_student
      .includes(:match)
      .order(created_at: :desc)
  end

  private

    def require_coach
      redirect_to root_path, alert: "无权访问" unless current_user.coach?
    end

    def require_student
      redirect_to root_path, alert: "无权访问" unless current_user.student?
    end
end
