class MatchPlayer < ApplicationRecord
  belongs_to :match
  belongs_to :user

  enum :source, { system_pull: 0, maintainer_upload: 1, user_sync: 2 }

  # Award enum values from Stratz API
  # MVP, TOP_CORE, TOP_SUPPORT, NONE
  AWARD_DISPLAY = {
    "MVP" => { text: "MVP", badge: "badge-warning" },
    "TOP_CORE" => { text: "最佳核心", badge: "badge-primary" },
    "TOP_SUPPORT" => { text: "最佳辅助", badge: "badge-secondary" },
    "NONE" => nil,
    nil => nil
  }.freeze

  # Position role names
  POSITION_ROLES = {
    1 => "核心",
    2 => "中单", 
    3 => "劣单",
    4 => "半辅",
    5 => "纯辅"
  }.freeze

  # Lane outcome display names
  LANE_OUTCOME_NAMES = {
    "advantage" => "线优",
    "even" => "均势",
    "disadvantage" => "线劣"
  }.freeze

  LANE_OUTCOME_BADGES = {
    "advantage" => "badge-success",
    "even" => "badge-ghost",
    "disadvantage" => "badge-error"
  }.freeze

  validates :match_id, uniqueness: { scope: :user_id }
  validates :hero_id, presence: true

  # Calculate position number (1-5)
  def position_number
    if position.present?
      position.gsub('POSITION_', '').to_i
    else
      fallback_position
    end
  end

  def position_name
    "#{position_number}号位"
  end

  def position_role
    POSITION_ROLES[position_number] || "未知"
  end

  # KDA calculation
  def kda
    return kills + assists if deaths.zero?
    ((kills + assists) / deaths.to_f).round(2)
  end

  # Hero image path
  def hero_image_path
    hero = Hero.find_by_id(hero_id)
    return nil unless hero
    
    hero_name = hero.name.sub('npc_dota_hero_', '')
    "heros/#{hero_name}.png"
  end

  def hero_name
    Hero.find_by_id(hero_id)&.cn_name || "未知英雄"
  end

  # Lane outcome display
  def lane_outcome_name
    LANE_OUTCOME_NAMES[lane_outcome] || "-"
  end

  def lane_outcome_badge_class
    LANE_OUTCOME_BADGES[lane_outcome] || "badge-ghost"
  end

  # Award display
  def award_display
    AWARD_DISPLAY[award]
  end

  def award_text
    award_display&.dig(:text)
  end

  def award_badge_class
    award_display&.dig(:badge) || "badge-ghost"
  end

  private

  def fallback_position
    slot = player_slot.to_i
    pos_in_team = slot < 128 ? slot : slot - 128
    
    case lane
    when 'MID_LANE'
      2
    when 'SAFE_LANE'
      (pos_in_team == 0) ? 1 : 5
    when 'OFF_LANE'
      (pos_in_team == 2) ? 3 : 4
    else
      case pos_in_team
      when 0 then 1
      when 1 then 2
      when 2 then 3
      when 3 then 4
      when 4 then 5
      else nil
      end
    end
  end
end
