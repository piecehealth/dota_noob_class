class ApiError < ApplicationRecord
  validates :api_name, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(error_type: type) }
  scope :today, -> { where(created_at: Date.current.beginning_of_day..) }

  def self.cleanup_old(days = 7)
    where("created_at < ?", days.days.ago).destroy_all
  end
end
