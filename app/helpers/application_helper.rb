module ApplicationHelper
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
end
