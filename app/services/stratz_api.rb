# frozen_string_literal: true

require "net/http"
require "json"

# Stratz GraphQL API Client
# Documentation: https://docs.stratz.com/
class StratzApi
  class Error < StandardError; end
  class RateLimitError < Error; end
  class ApiError < Error; end

  API_ENDPOINT = "https://api.stratz.com/graphql"
  USER_AGENT = "STRATZ_API"

  # Batch size for bulk queries (Stratz API supports up to 50 players per request)
  BATCH_SIZE = 50

  def initialize(token = nil)
    @token = token || default_token
    raise Error, "STRATZ_API_TOKEN not configured" if @token.nil? || @token.empty?
  end

  # Fetch player profiles for multiple players in one request
  # @param steam_account_ids [Array<Integer>] Array of Steam account IDs
  # @return [Hash] { steam_account_id => profile_hash }
  def batch_player_profiles(steam_account_ids)
    results = {}
    
    # Filter only valid numeric steam IDs
    valid_ids = steam_account_ids.map(&:to_s).select { |id| id =~ /^\d+$/ }.map(&:to_i)
    
    if valid_ids.empty?
      Rails.logger.warn "[StratzApi] batch_player_profiles called with no valid steam IDs"
      return results
    end

    valid_ids.each_slice(BATCH_SIZE) do |batch_ids|
      query = build_batch_profiles_query(batch_ids)
      response = execute_query(query)
      data = response.dig("data") || {}

      batch_ids.each do |steam_id|
        player_data = data["player#{steam_id}"]
        results[steam_id] = transform_profile(player_data) if player_data
      end
    end

    results
  end

  # Fetch single player profile
  # @param steam_account_id [Integer]
  # @return [Hash]
  def player_profile(steam_account_id)
    results = batch_player_profiles([ steam_account_id ])
    results[steam_account_id]
  end

  # Fetch both matches and profiles for multiple players
  # @param steam_account_ids [Array<Integer>]
  # @param since_days [Integer] Number of days back to fetch matches
  # @param users_by_steam_id [Hash] { steam_id => user_object }
  # @return [Hash] { steam_account_id => { matches: [], profile: {} } }
  def batch_sync_players(steam_account_ids, since_days: 14, users_by_steam_id: {})
    results = {}

    # Filter out invalid steam IDs
    batch_ids = steam_account_ids.compact.reject { |id| id.to_s.blank? || id.to_s == '0' }
    
    if batch_ids.empty?
      Rails.logger.warn "[StratzApi] batch_sync_players called with no valid steam IDs"
      return results
    end

    # Calculate start date timestamp
    start_date = since_days.days.ago.to_i

    batch_ids.each_slice(BATCH_SIZE) do |slice_ids|
      query = build_batch_sync_query(slice_ids, start_date)
      response = execute_query(query)
      data = response.dig("data") || {}

      slice_ids.each do |steam_id|
        player_data = data["player#{steam_id}"]
        next unless player_data

        matches = player_data.dig("matches") || []

        # Create/update matches in database
        matches.each do |match_data|
          transformed = transform_match(match_data, steam_id)
          Match.create_from_api(transformed, users_by_steam_id) if transformed
        end

        results[steam_id] = {
          matches: matches.map { |m| transform_match(m, steam_id) },
          profile: transform_profile(player_data)
        }
      end
    end

    results
  end

  private

  def default_token
    Rails.application.credentials.stratz_token || ENV["STRATZ_API_TOKEN"]
  end

  def build_batch_profiles_query(steam_ids)
    # Ensure all steam_ids are valid integers
    valid_ids = steam_ids.map(&:to_s).select { |id| id =~ /^\d+$/ }.map(&:to_i)
    
    players_queries = valid_ids.map do |steam_id|
      <<~GRAPHQL
        player#{steam_id}: player(steamAccountId: #{steam_id}) {
          steamAccountId
          steamAccount {
            profileUri
            name
            avatar
            isDotaPlusSubscriber
          }
          ranks {
            rank
          }
          matchCount
          winCount
        }
      GRAPHQL
    end

    "query { #{players_queries.join("\n")} }"
  end

  def build_batch_sync_query(steam_ids, start_date)
    # Ensure all steam_ids are valid integers
    valid_ids = steam_ids.map(&:to_s).select { |id| id =~ /^\d+$/ }.map(&:to_i)
    
    players_queries = valid_ids.map do |steam_id|
      # Use startDateTime to filter matches from the specified date
      <<~GRAPHQL
        player#{steam_id}: player(steamAccountId: #{steam_id}) {
          steamAccountId
          steamAccount {
            name
            avatar
            isDotaPlusSubscriber
          }
          ranks {
            rank
          }
          matchCount
          winCount
          matches(request: { startDateTime: #{start_date}, take: 100 }) {
            id
            didRadiantWin
            durationSeconds
            startDateTime
            lobbyType
            gameMode
            rank
            players {
              steamAccountId
              steamAccount {
                name
              }
              isRadiant
              heroId
              kills
              deaths
              assists
              leaverStatus
              partyId
              lane
              variant
              award
            }
            topLaneOutcome
            midLaneOutcome
            bottomLaneOutcome
          }
        }
      GRAPHQL
    end

    "query { #{players_queries.join("\n")} }"
  end

  def execute_query(query)
    uri = URI(API_ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{@token}"
    request["User-Agent"] = USER_AGENT
    request.body = { query: query }.to_json

    response = http.request(request)

    case response.code.to_i
    when 200
      parse_response(response.body)
    when 429
      raise RateLimitError, "Rate limit exceeded"
    else
      raise ApiError, "HTTP #{response.code}: #{response.body}"
    end
  rescue Net::OpenTimeout, Net::ReadTimeout
    raise Error, "Request timeout"
  rescue SocketError, Errno::ECONNREFUSED => e
    raise Error, "Connection error: #{e.message}"
  end

  def parse_response(body)
    data = JSON.parse(body)

    if data["errors"]
      raise ApiError, data["errors"].map { |e| e["message"] }.join(", ")
    end

    data
  rescue JSON::ParserError => e
    raise ApiError, "Invalid JSON response: #{e.message}"
  end

  # Game mode name to ID mapping
  GAME_MODE_IDS = {
    "UNKNOWN" => 0,
    "ALL_PICK" => 1,
    "ALL_PICK_RANKED" => 22,  # 排位全英雄选择（抢选）
    "CAPTAINS_MODE" => 2,
    "RANDOM_DRAFT" => 3,
    "SINGLE_DRAFT" => 4,
    "ALL_RANDOM" => 5,
    "INTRO" => 6,
    "DIRETIDE" => 7,
    "REVERSE_CAPTAINS_MODE" => 8,
    "GREEVILING" => 9,
    "TUTORIAL" => 10,
    "MID_ONLY" => 11,
    "LEAST_PLAYED" => 12,
    "NEW_PLAYER_POOL" => 13,
    "COMPENDIUM_MATCHMAKING" => 14,
    "CUSTOM" => 15,
    "CAPTAINS_DRAFT" => 16,
    "BALANCED_DRAFT" => 17,
    "ABILITY_DRAFT" => 18,
    "EVENT" => 19,
    "ALL_RANDOM_DEATH_MATCH" => 20,
    "SOLO_MID" => 21,
    "ALL_DRAFT" => 22,
    "TURBO" => 23
  }.freeze

  # Lobby type name to ID mapping
  LOBBY_TYPE_IDS = {
    "NORMAL" => 0,
    "PRACTICE" => 1,
    "TOURNAMENT" => 2,
    "TUTORIAL" => 3,
    "COOP_BOTS" => 4,
    "TEAM_RANKED" => 5,
    "SOLO_RANKED" => 6,
    "RANKED" => 7,
    "ONE_V_ONE" => 8,
    "BATTLE_CUP" => 9,
    "UNRANKED" => 0  # Treat unranked as normal
  }.freeze

  def transform_match(match, steam_account_id)
    # Convert steam_account_id to integer for comparison
    steam_id_int = steam_account_id.to_i
    player_data = match["players"]&.find { |p| p["steamAccountId"] == steam_id_int }
    return nil if player_data.nil?

    on_radiant = player_data["isRadiant"]

    # Convert game mode string to ID
    game_mode_str = match["gameMode"].to_s.upcase
    game_mode_id = GAME_MODE_IDS[game_mode_str] || 0

    # Convert lobby type string to ID
    lobby_type_str = match["lobbyType"].to_s.upcase
    lobby_type_id = LOBBY_TYPE_IDS[lobby_type_str] || 0

    {
      "match_id" => match["id"],
      "player_slot" => on_radiant ? 0 : 128,
      "radiant_win" => match["didRadiantWin"],
      "hero_id" => player_data["heroId"],
      "hero_variant" => player_data["variant"],
      "kills" => player_data["kills"] || 0,
      "deaths" => player_data["deaths"] || 0,
      "assists" => player_data["assists"] || 0,
      "imp" => player_data["imp"],
      "role" => player_data["role"],
      "position" => player_data["position"],
      "lane" => player_data["lane"],
      "lane_outcome" => calculate_lane_outcome(player_data, match),
      "duration" => match["durationSeconds"],
      "start_time" => match["startDateTime"],
      "game_mode" => game_mode_id,
      "lobby_type" => lobby_type_id,
      "average_rank" => match["rank"],
      "party_size" => calculate_party_size(match["players"], player_data["partyId"]),
      "leaver_status" => player_data["leaverStatus"] == "NONE" ? 0 : 1,
      "award" => player_data["award"],
      "raw" => match
    }
  end

  def transform_profile(player_data)
    return nil if player_data.nil?

    latest_rank = player_data["ranks"]&.first&.[]("rank")

    {
      steam_account_id: player_data["steamAccountId"],
      name: player_data.dig("steamAccount", "name"),
      avatar: player_data.dig("steamAccount", "avatar"),
      profile_uri: player_data.dig("steamAccount", "profileUri"),
      rank: latest_rank,
      match_count: player_data["matchCount"],
      win_count: player_data["winCount"],
      is_dota_plus: player_data.dig("steamAccount", "isDotaPlusSubscriber")
    }
  end

  def calculate_party_size(players, party_id)
    return 1 if party_id.nil? || party_id == 0
    players.count { |p| p["partyId"] == party_id }
  end

  # Calculate lane outcome for a player based on lane results
  # Returns: "advantage", "even", "disadvantage", or nil
  def calculate_lane_outcome(player_data, match)
    lane = player_data["lane"]
    is_radiant = player_data["isRadiant"]

    # Map lane to outcome field
    outcome_field = case lane
    when "SAFE_LANE"
      is_radiant ? "bottomLaneOutcome" : "topLaneOutcome"
    when "OFF_LANE"
      is_radiant ? "topLaneOutcome" : "bottomLaneOutcome"
    when "MID_LANE"
      "midLaneOutcome"
    else
      return nil
    end

    outcome = match[outcome_field]
    return nil if outcome.nil?

    # Parse outcome enum value
    # Typical values: RADIANT_VICTORY, RADIANT_STOMP, DIRE_VICTORY, DIRE_STOMP, DRAW, etc.
    outcome_str = outcome.to_s.upcase

    # Determine if player won their lane
    player_won = if is_radiant
      outcome_str.include?("RADIANT")
    else
      outcome_str.include?("DIRE")
    end

    # Determine advantage level
    if player_won
      if outcome_str.include?("STOMP") || outcome_str.include?("DOMINATE")
        "advantage"  # 大优
      else
        "advantage"  # 线优
      end
    elsif outcome_str.include?("DRAW") || outcome_str.include?("EVEN")
      "even"  # 均势
    else
      "disadvantage"  # 线劣
    end
  end
end
