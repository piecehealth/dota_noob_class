require "net/http"

class User < ApplicationRecord
  has_secure_password

  belongs_to :classroom, optional: true
  belongs_to :group, optional: true
  has_many :match_players, dependent: :destroy
  has_many :matches, through: :match_players
  has_many :rank_snapshots, dependent: :destroy
  has_many :daily_stats, dependent: :destroy

  validates :display_name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  enum :role, { student: 0, coach: 1, assistant: 2 }

  scope :students_with_dota_id, -> { where.not(dota2_player_id: nil).where(is_dota2_id_invalid: [nil, false]) }
  scope :active_students, -> { where.not(dota2_player_id: nil).where(is_dota2_id_invalid: [nil, false]) }
  scope :student, -> { where.not(dota2_player_id: nil).where(is_dota2_id_invalid: [nil, false]) }

  def admin? = is_admin?

  def identity_label
    # Assistant role shows as辅导员 even if they have admin privileges
    if assistant?
      "#{classroom&.number}班辅导员"
    elsif admin?
      "管理员"
    elsif classroom || group
      "#{classroom&.number}班#{group&.number}组#{role_name}"
    else
      display_name
    end
  end

  def role_name
    case role
    when "student" then "学员"
    when "coach" then "教练"
    when "assistant" then "辅导员"
    else ""
    end
  end

  # Update rank info from Stratz API
  def update_rank_info!
    return unless dota2_player_id

    profile = StratzApi.new.player_profile(dota2_player_id)
    return if profile.nil?

    new_rank = profile[:rank] || 0
    new_highest = [ highest_rank, new_rank ].max

    update!(
      current_rank: new_rank,
      highest_rank: new_highest,
      total_matches: profile[:match_count] || 0,
      total_wins: profile[:win_count] || 0,
      rank_updated_at: Time.current
    )

    RankSnapshot.capture_for_user(self, profile)

    { rank: new_rank, highest_rank: new_highest }
  rescue StratzApi::Error => e
    Rails.logger.error "Failed to update rank for user #{id}: #{e.message}"
    nil
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
end
