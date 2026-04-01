class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      # Match-level fields only
      t.bigint  :match_id,     null: false
      t.integer :duration,     null: false   # seconds
      t.datetime :played_at,   null: false
      t.integer :game_mode
      t.integer :lobby_type
      t.integer :average_rank

      t.timestamps
    end

    add_index :matches, :match_id, unique: true
    add_index :matches, :played_at
  end
end
