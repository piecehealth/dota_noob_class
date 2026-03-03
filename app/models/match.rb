class Match < ApplicationRecord
  belongs_to :user

  has_one :coaching_request, dependent: :destroy

  serialize :raw_data, coder: JSON

  enum :source, { system_pull: 0, maintainer_upload: 1, user_sync: 2 }

  # Lower value = higher priority
  SOURCE_PRIORITY = { system_pull: 0, maintainer_upload: 1, user_sync: 2 }.freeze

  LOBBY_TYPE_NAMES = {
    0 => "普通匹配",
    1 => "练习赛",
    2 => "锦标赛",
    4 => "人机对战",
    5 => "队伍匹配",
    6 => "单排匹配",
    7 => "排位赛",
    8 => "中路单挑",
    9 => "战斗杯"
  }.freeze

  def lobby_type_name
    LOBBY_TYPE_NAMES.fetch(lobby_type, "未知")
  end

  validates :match_id, presence: true, uniqueness: { scope: :user_id }
  validates :player_slot, :hero_id, :kills, :deaths, :assists, :duration, :played_at, presence: true
  validates :on_radiant, :won, inclusion: { in: [ true, false ] }

  class << self
    # Build and persist from raw OpenDota API hash.
    # If the same match already exists for this user, only overwrites when
    # the incoming source has strictly higher priority.
    def upsert_from_raw(user:, raw:, source:)
      attrs = build_attrs(raw:, source:)
      existing = find_by(user:, match_id: raw["match_id"])

      if existing
        return existing unless higher_priority?(source, existing.source)
        existing.update!(attrs)
        existing
      else
        create!(attrs.merge(user:))
      end
    end

    private

      def build_attrs(raw:, source:)
        on_radiant = (raw["player_slot"] & 128) == 0
        won        = on_radiant == raw["radiant_win"]

        {
          raw_data:      raw,
          match_id:      raw["match_id"],
          player_slot:   raw["player_slot"],
          on_radiant:,
          won:,
          hero_id:       raw["hero_id"],
          hero_variant:  raw["hero_variant"],
          kills:         raw["kills"],
          deaths:        raw["deaths"],
          assists:       raw["assists"],
          duration:      raw["duration"],
          played_at:     Time.at(raw["start_time"]),
          game_mode:     raw["game_mode"],
          lobby_type:    raw["lobby_type"],
          average_rank:  raw["average_rank"],
          party_size:    raw["party_size"],
          leaver_status: raw["leaver_status"] || 0,
          source:
        }
      end

      def higher_priority?(incoming, existing)
        SOURCE_PRIORITY[incoming.to_sym] < SOURCE_PRIORITY[existing.to_sym]
      end
  end
end
