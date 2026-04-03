class Match < ApplicationRecord
  has_many :match_players, dependent: :destroy
  has_many :users, through: :match_players

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

  GAME_MODE_NAMES = {
    0 => "未知",
    1 => "全英雄选择",
    2 => "队长模式",
    3 => "随机选秀",
    4 => "单中模式",
    5 => "全随机",
    6 => "开局",
    7 => "夜魇暗潮",
    8 => "反队长模式",
    9 => "贪魔模式",
    10 => "教程",
    11 => "中路线",
    12 => "生疏模式",
    13 => "新手模式",
    14 => "Compendium Matchmaking",
    15 => "自定义游戏",
    16 => "队长征召",
    17 => "平衡征召",
    18 => "技能征召",
    19 => "活动",
    20 => "全英雄随机死亡竞赛",
    21 => "中路单挑",
    22 => "全英雄选择（抢选）",
    23 => "加速模式"
  }.freeze

  validates :match_id, presence: true, uniqueness: true
  validates :played_at, :duration, presence: true

  scope :recent, -> { order(played_at: :desc) }
  scope :today, -> { where(played_at: Date.current.all_day) }
  scope :yesterday, -> { where(played_at: Date.yesterday.all_day) }
  scope :this_week, -> { where(played_at: 1.week.ago..Time.current) }
  scope :ranked, -> { joins(:match_players).where(match_players: { lobby_type: 7 }).distinct }

  def lobby_type_name
    LOBBY_TYPE_NAMES.fetch(lobby_type, "未知")
  end

  def game_mode_name
    GAME_MODE_NAMES.fetch(game_mode, "未知")
  end

  # 段位名称映射 (rank 0-80+)
  RANK_NAMES = {
    0 => "先锋",
    1 => "卫士",
    2 => "中军",
    3 => "统帅",
    4 => "传奇",
    5 => "万古流芳",
    6 => "超凡入圣",
    7 => "冠绝一世"
  }.freeze

  def rank_name
    return nil if average_rank.nil?

    tier = average_rank / 10
    star = (average_rank % 10) + 1
    tier_name = RANK_NAMES.fetch(tier, "未知")

    # 冠绝一世没有星级
    if tier >= 7
      tier_name
    else
      "#{tier_name} #{star}星"
    end
  end

  def won_by?(user)
    match_players.find_by(user: user)&.won
  end

  def duration_formatted
    minutes = duration / 60
    seconds = duration % 60
    "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
  end

  class << self
    # Create match and associated match_players from API data
    # api_data should contain match info and array of players
    def create_from_api(api_data, users_by_steam_id = {})
      match = find_or_initialize_by(match_id: api_data["match_id"])

      # Update match basic info
      match.assign_attributes(
        played_at: parse_time(api_data["start_time"] || api_data["startDateTime"]),
        duration: api_data["duration"] || api_data["durationSeconds"] || 0,
        game_mode: api_data["game_mode"],
        lobby_type: api_data["lobby_type"] || api_data["lobbyType"],
        average_rank: api_data["average_rank"] || api_data["rank"],
        raw_data: api_data["raw"]  # Save full match data
      )
      match.save!

      # Create/update match_players from raw data
      # api_data["raw"] contains the full match data with all players
      raw_match = api_data["raw"]
      all_players = raw_match&.dig("players") || []

      # Find the player(s) from our system
      all_players.each do |player_data|
        steam_id = player_data["steamAccountId"].to_s
        user = users_by_steam_id[steam_id]
        next unless user # Skip if user not in our system

        match_player = match.match_players.find_or_initialize_by(user: user)
        match_player.assign_attributes(
          hero_id: player_data["heroId"],
          hero_variant: player_data["variant"],
          kills: player_data["kills"] || 0,
          deaths: player_data["deaths"] || 0,
          assists: player_data["assists"] || 0,
          imp: player_data["imp"],
          role: player_data["role"],
          position: player_data["position"],
          lane: player_data["lane"],
          lane_outcome: api_data["lane_outcome"],  # Calculated in transform_match
          award: player_data["award"],
          player_slot: player_data["isRadiant"] ? 0 : 128,
          on_radiant: player_data["isRadiant"],
          won: raw_match["didRadiantWin"] == player_data["isRadiant"],
          party_size: calculate_party_size(all_players, player_data["partyId"]),
          leaver_status: player_data["leaverStatus"] == "NONE" ? 0 : 1,
          raw_data: player_data,
          source: :system_pull
        )
        match_player.save!
      end

      match
    end

    private

    def parse_time(time_value)
      case time_value
      when Integer
        Time.at(time_value)
      when String
        Time.parse(time_value)
      else
        time_value
      end
    end

    def calculate_party_size(players, party_id)
      return 1 if party_id.nil? || party_id == 0
      players.count { |p| p["partyId"] == party_id }
    end
  end
end
