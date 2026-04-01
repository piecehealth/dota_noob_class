# frozen_string_literal: true

namespace :dota do
  namespace :stats do
    desc "Sync matches for a specific user (provide USER_ID), last 14 days"
    task sync_user: :environment do
      user_id = ENV["USER_ID"]
      raise "Please provide USER_ID" unless user_id

      user = User.find(user_id)
      puts "Syncing matches for #{user.display_name} (Player ID: #{user.dota2_player_id})..."
      
      count = user.sync_matches(since_days: 14)
      puts "Synced #{count} matches (last 14 days)."
      
      puts "Updating rank info..."
      result = user.update_rank_info!
      puts "Rank: #{result[:rank]}, Highest: #{result[:highest_rank]}" if result
    end

    desc "Sync all active students (batch mode, ~10 players per API request)"
    task sync_all: :environment do
      puts "Starting batch sync for all active students..."
      result = BatchSyncAllPlayersJob.perform_now
      puts "Processed #{result[:processed]}/#{result[:total_users]} users, #{result[:errors]} errors."
    end

    desc "Calculate daily stats for yesterday"
    task calculate_daily: :environment do
      date = ENV["DATE"] ? Date.parse(ENV["DATE"]) : Date.yesterday
      puts "Calculating daily stats for #{date}..."
      result = CalculateDailyStatsJob.perform_now(date)
      puts "Calculated stats for #{result[:calculated]} users."
    end

    desc "Show top performers for a date"
    task top_performers: :environment do
      date = ENV["DATE"] ? Date.parse(ENV["DATE"]) : Date.yesterday
      puts "\nTop performers for #{date}:\n"
      puts "-" * 80
      
      stats = StatsService.top_performers(date: date, metric: :wins_count, limit: 10)
      stats.each_with_index do |stat, i|
        puts "#{i + 1}. #{stat.user.display_name} - #{stat.wins_count} wins (#{stat.win_rate}% WR)"
      end
    end

    desc "Show star students (most improved)"
    task stars: :environment do
      days = ENV["DAYS"]&.to_i || 7
      puts "\nStar students (past #{days} days):\n"
      puts "-" * 80
      
      stars = StatsService.star_students(since: days.days.ago, limit: 10)
      stars.each_with_index do |star, i|
        puts "#{i + 1}. #{star[:user].display_name} - +#{star[:rank_improvement]} rank (#{star[:days_tracked]} days)"
      end
    end

    desc "Test exception tracking"
    task test_exception: :environment do
      puts "Creating a test exception..."
      begin
        raise "This is a test exception for exception-track"
      rescue => e
        # Create exception log manually
        title = e.message || "None"
        messages = []
        messages << "--------------------------------------------------"
        messages << ""
        messages << e.inspect
        unless e.backtrace.blank?
          messages << "\n"
          messages << e.backtrace
        end
        
        ExceptionTrack::Log.create(title: title[0, 200], body: messages.join("\n"))
        puts "Exception logged successfully!"
        puts "Total exceptions in database: #{ExceptionTrack::Log.count}"
      end
    end

    desc "Test batch API query (last 14 days)"
    task test_batch: :environment do
      users = User.active_students.limit(5)
      puts "Testing batch query for #{users.count} users (last 14 days)..."
      
      api = StratzApi.new
      player_ids = users.map(&:dota2_player_id)
      
      start_time = Time.current
      results = api.batch_sync_players(player_ids, since_days: 14)
      duration = Time.current - start_time
      
      puts "Query completed in #{duration.round(2)}s"
      puts "Results:"
      results.each do |player_id, data|
        puts "  Player #{player_id}: #{data[:matches].count} matches, rank: #{data[:profile]&.dig(:rank) || 'N/A'}"
      end
    end
  end
end
