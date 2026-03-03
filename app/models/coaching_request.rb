class CoachingRequest < ApplicationRecord
  MAX_WEEKLY_COACHING_REQUESTS = 3

  enum :status, { requested: 0, in_progress: 1, completed: 2 }

  belongs_to :match
  belongs_to :student, class_name: "User"
  belongs_to :coach, class_name: "User", optional: true

  has_many :events, class_name: "CoachingRequestEvent", dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :match, uniqueness: true

  class << self
    def weekly_count_for(student)
      where(student: student)
        .where(created_at: Time.current.beginning_of_week..Time.current.end_of_week)
        .count
    end
  end

  def transition_to!(new_status, operator:)
    old_status = status
    update!(status: new_status)
    events.create!(operator: operator, from_status: old_status, to_status: new_status.to_s)
  end
end
