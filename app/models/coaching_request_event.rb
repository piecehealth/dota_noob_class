class CoachingRequestEvent < ApplicationRecord
  enum :from_status, { requested: 0, in_progress: 1, completed: 2 }, prefix: :from
  enum :to_status, { requested: 0, in_progress: 1, completed: 2 }, prefix: :to

  belongs_to :coaching_request
  belongs_to :operator, class_name: "User"
end
