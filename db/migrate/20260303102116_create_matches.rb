class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      t.references :user, null: false, foreign_key: true

      # Raw data backup
      t.text :raw_data, null: false

      # Normalized fields (derived from raw)
      t.bigint  :match_id,     null: false
      t.integer :player_slot,  null: false
      t.boolean :on_radiant,   null: false
      t.boolean :won,          null: false
      t.integer :hero_id,      null: false
      t.integer :hero_variant
      t.integer :kills,        null: false
      t.integer :deaths,       null: false
      t.integer :assists,      null: false
      t.integer :duration,     null: false   # seconds
      t.datetime :played_at,   null: false   # from start_time
      t.integer :game_mode
      t.integer :lobby_type
      t.integer :average_rank
      t.integer :party_size
      t.integer :leaver_status, null: false, default: 0

      # Source: 0=system_pull, 1=maintainer_upload, 2=user_sync
      # Priority: system_pull > maintainer_upload > user_sync
      t.integer :source, null: false, default: 2

      t.timestamps
    end

    add_index :matches, [ :user_id, :match_id ], unique: true
    add_index :matches, :played_at
    add_index :matches, :match_id

    add_check_constraint :matches, "source IN (0, 1, 2)", name: "check_matches_source"
  end
end
