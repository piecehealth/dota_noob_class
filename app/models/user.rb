require "net/http"

class User < ApplicationRecord
  has_secure_password
  has_secure_token :activation_token

  enum :role, { student: 0, coach: 1, assistant: 2 }

  belongs_to :classroom, optional: true
  belongs_to :group, optional: true
  has_many :matches, dependent: :destroy
  has_many :coaching_requests_as_student, class_name: "CoachingRequest", foreign_key: :student_id, dependent: :destroy
  has_many :coaching_requests_as_coach,   class_name: "CoachingRequest", foreign_key: :coach_id,   dependent: :nullify

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
  def admin? = is_admin?

  def role_name = ROLE_NAMES[role]

  def identity_label
    case role
    when "student"
      "#{classroom&.name}#{group&.number}组学员"
    when "coach"
      "#{classroom&.name}#{group&.number}组教练"
    when "assistant"
      "#{classroom&.name}辅导员"
    end
  end

  def activate!(username:, password:, password_confirmation:)
    update!(username:, password:, password_confirmation:, activated_at: Time.current)
  end

  # 拉取最近 29 天的对局数据并入库，返回处理的场数。
  # 仅对学员有效（需要 dota2_player_id）。
  # 网络或 API 异常时抛出 User::SyncError。
  def sync_matches
    raise SyncError, "非学员账号无法同步" unless student?

    raw_list = fetch_recent_matches
    raw_list.each { |raw| Match.upsert_from_raw(user: self, raw: raw, source: :system_pull) }
    raw_list.size
  end

  class SyncError < StandardError; end

  private

    OPENDOTA_MATCHES_URL = "https://api.opendota.com/api/players/%s/matches?date=29"

    def fetch_recent_matches
      uri = URI(OPENDOTA_MATCHES_URL % dota2_player_id)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 15) do |http|
        http.get(uri.request_uri)
      end

      raise SyncError, "OpenDota API 返回错误：HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue Net::OpenTimeout, Net::ReadTimeout
      raise SyncError, "请求 OpenDota API 超时，请稍后重试"
    rescue SocketError, Errno::ECONNREFUSED => e
      raise SyncError, "无法连接 OpenDota API：#{e.message}"
    end
end
