module ApplicationHelper
  # Hero image path - uses local images from assets
  def hero_image_path(hero_id)
    hero = Hero.find_by_id(hero_id)
    return "heros/placeholder.svg" unless hero

    # Extract filename from npc_dota_hero_xxx format
    filename = hero.name.sub("npc_dota_hero_", "")
    "heros/#{filename}.png"
  end

  def hero_name(hero_id)
    Hero.find_by_id(hero_id)&.cn_name || "未知英雄(#{hero_id})"
  end

  CONTRIBUTION_COLORS = [
    "bg-base-200",    # 0 场
    "bg-green-200",   # 1
    "bg-green-300",   # 2
    "bg-green-400",   # 3-4
    "bg-green-600",   # 5-6
    "bg-green-800"   # 7+
  ].freeze

  def contribution_color(count)
    CONTRIBUTION_COLORS[[ count, CONTRIBUTION_COLORS.length - 1 ].min]
  end

  def format_duration(seconds)
    "%d:%02d" % [ seconds / 60, seconds % 60 ]
  end

  LOBBY_TYPE_BADGE = {
    0 => "badge-ghost",
    1 => "badge-ghost",
    2 => "badge-accent",
    4 => "badge-neutral",
    5 => "badge-secondary",
    6 => "badge-warning",
    7 => "badge-info",
    8 => "badge-error",
    9 => "badge-accent"
  }.freeze

  def lobby_type_badge_class(lobby_type)
    LOBBY_TYPE_BADGE.fetch(lobby_type, "badge-ghost")
  end

  # Format rank number to readable string
  def format_rank(rank)
    return "-" if rank.nil? || rank <= 0

    tier = (rank / 10) + 1
    stars = (rank % 10) + 1

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

    tier_name = tier_names[tier] || "未知"
    "#{tier_name} #{stars}⭐"
  end
end
