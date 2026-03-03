class ClassroomsController < ApplicationController
  before_action :require_authentication
  before_action :require_coach!

  def mine
    classroom = current_user.classroom
    all_groups = classroom.groups.order(:number)

    # Coach's own group first, then rest by number
    @groups = all_groups.sort_by { |g| [ g.id == current_user.group_id ? 0 : 1, g.number ] }

    student_ids_by_group = User.where(role: :student, group_id: @groups.map(&:id))
                               .order(:display_name)
                               .includes(:matches)
                               .group_by(&:group_id)

    @students_by_group = @groups.index_with { |g| student_ids_by_group[g.id] || [] }
  end

  private

    def require_coach!
      redirect_to root_path, alert: "无权限" unless current_user.coach? || current_user.admin?
    end
end
