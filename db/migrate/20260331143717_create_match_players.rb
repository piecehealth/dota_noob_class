class CreateMatchPlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :match_players do |t|
      t.references :match, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      # Player performance in match
      t.integer :hero_id
      t.integer :hero_variant
      t.integer :kills, default: 0
      t.integer :deaths, default: 0
      t.integer :assists, default: 0
      t.integer :imp  # Impact score from Stratz

      # Position and role
      t.string :role
      t.string :position  # POSITION_1, POSITION_2, etc.
      t.string :lane  # SAFE_LANE, MID_LANE, OFF_LANE
      t.string :lane_outcome  # advantage, even, disadvantage
      t.integer :player_slot
      t.boolean :on_radiant
      t.boolean :won

      # Party info
      t.integer :party_size, default: 1
      t.integer :leaver_status, default: 0

      # Award from Stratz (MVP, TOP_CORE, TOP_SUPPORT, NONE)
      t.string :award

      # Metadata
      t.json :raw_data
      t.integer :source, default: 0  # system_pull: 0, maintainer_upload: 1, user_sync: 2

      # Editable fields
      t.string :lane_advantage  # manual override
      t.boolean :is_mvp  # manual override
      t.boolean :is_svp  # manual override

      t.timestamps
    end

    add_index :match_players, [:match_id, :user_id], unique: true
    add_index :match_players, :hero_id
    add_index :match_players, [:user_id, :won]
    add_index :match_players, :award
  end
end
