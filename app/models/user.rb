class User < ApplicationRecord
  has_secure_password
  has_secure_token :activation_token

  enum :role, { student: 0, coach: 1, assistant: 2 }

  belongs_to :classroom, optional: true
  belongs_to :group, optional: true

  validates :display_name, presence: true
  validates :dota2_player_id, presence: true, if: :student?
  validates :group, presence: true, if: -> { student? || coach? }
  validates :username, presence: true, if: :activated?
  validates :username, uniqueness: { allow_nil: true }
  validates :password, length: { minimum: 6 }, allow_nil: true

  scope :activated, -> { where.not(activated_at: nil) }
  scope :pending,   -> { where(activated_at: nil) }

  ROLE_NAMES = { "student" => "学员", "coach" => "教练", "assistant" => "辅导员" }.freeze

  def activated? = activated_at.present?

  def role_name = ROLE_NAMES[role]

  def activate!(username:, password:, password_confirmation:)
    update!(username:, password:, password_confirmation:, activated_at: Time.current)
  end
end
