class CreateDailyStats < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_stats do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      
      # Match statistics
      t.integer :matches_count, null: false, default: 0
      t.integer :wins_count, null: false, default: 0
      t.integer :losses_count, null: false, default: 0
      
      # Performance metrics
      t.integer :total_kills, null: false, default: 0
      t.integer :total_deaths, null: false, default: 0
      t.integer :total_assists, null: false, default: 0
      t.float :avg_kda, default: 0.0
      
      # Time played (in seconds)
      t.integer :total_duration, null: false, default: 0
      
      # Rank at end of day
      t.integer :end_of_day_rank
      
      # Daily change
      t.integer :rank_change, default: 0
      
      t.timestamps
    end

    add_index :daily_stats, [:user_id, :date], unique: true
    add_index :daily_stats, :date
    add_index :daily_stats, [:date, :matches_count]
  end
end
