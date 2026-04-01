require "net/http"

class User < ApplicationRecord
  has_secure_password
  has_secure_token :activation_token

  enum :role, { student: 0, coach: 1, assistant: 2 }

  belongs_to :classroom, optional: true
  belongs_to :group, optional: true
  has_many :match_players, dependent: :destroy
  has_many :matches, through: :match_players
  has_many :coaching_requests_as_student, class_name: "CoachingRequest", foreign_key: :student_id, dependent: :destroy
  has_many :coaching_requests_as_coach,   class_name: "CoachingRequest", foreign_key: :coach_id,   dependent: :nullify
  has_many :rank_snapshots, dependent: :destroy
  has_many :daily_stats, dependent: :destroy

  validates :display_name, presence: true
  validates :dota2_player_id, presence: true, if: :student?
  validates :group, presence: true, if: -> { student? || coach? }
  validates :username, presence: true, if: :activated?
  validates :username, uniqueness: { allow_nil: true }
  validates :password, length: { minimum: 6 }, allow_nil: true

  scope :activated, -> { where.not(activated_at: nil) }
  scope :pending,   -> { where(activated_at: nil) }
  scope :students_with_dota_id, -> { student.where.not(dota2_player_id: nil) }
  scope :active_students, -> { student.activated.where.not(dota2_player_id: nil) }

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

  # Update rank info from Stratz API
  def update_rank_info!
    return unless student? && dota2_player_id

    profile = StratzApi.new.player_profile(dota2_player_id)
    return if profile.nil?

    new_rank = profile[:rank] || 0
    
    # Update highest rank if current is higher
    new_highest = [highest_rank, new_rank].max
    
    update!(
      current_rank: new_rank,
      highest_rank: new_highest,
      total_matches: profile[:match_count] || 0,
      total_wins: profile[:win_count] || 0,
      rank_updated_at: Time.current
    )
    
    # Also create a rank snapshot
    RankSnapshot.capture_for_user(self, profile)
    
    { rank: new_rank, highest_rank: new_highest }
  rescue StratzApi::Error => e
    Rails.logger.error "Failed to update rank for user #{id}: #{e.message}"
    nil
  end

  # 拉取最近的对局数据并入库，返回处理的场数。
  # 仅对学员有效（需要 dota2_player_id）。
  # 网络或 API 异常时抛出 User::SyncError。
  def sync_matches(since_days: 14)
    raise SyncError, "非学员账号无法同步" unless student?
    raise SyncError, "未设置 Dota2 Player ID" if dota2_player_id.nil?

    api = StratzApi.new
    results = api.batch_sync_players([dota2_player_id], since_days: since_days)
    data = results[dota2_player_id]
    
    return 0 unless data

    matches = data[:matches].compact
    matches.each do |raw|
      Match.upsert_from_raw(user: self, raw: raw, source: :system_pull)
    end
    
    matches.size
  rescue StratzApi::Error => e
    raise SyncError, "Stratz API 错误：#{e.message}"
  end

  # Get formatted rank display
  def display_rank
    return "未校准" if current_rank.nil? || current_rank <= 0
    
    tier = (current_rank / 10) + 1
    stars = (current_rank % 10) + 1
    
    tier_names = {
      1 => "先锋",
      2 => "卫士",
      3 => "中军",
      4 => "统帅",
      5 => "传奇",
      6 => "万古",
      7 => "超凡",
      8 => "冠绝"
    }
    
    "#{tier_names[tier] || '未知'} #{stars}星"
  end

  # Calculate current win rate
  def win_rate
    return 0 if total_matches.nil? || total_matches.zero?
    (total_wins.to_f / total_matches * 100).round(1)
  end

  class SyncError < StandardError; end
end
