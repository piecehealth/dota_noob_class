class CreateRankSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :rank_snapshots do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :rank, null: false, comment: "Stratz rank value"
      t.integer :match_count, null: false, default: 0
      t.integer :win_count, null: false, default: 0
      t.datetime :captured_at, null: false

      t.timestamps
    end

    add_index :rank_snapshots, [ :user_id, :captured_at ]
    add_index :rank_snapshots, :captured_at
  end
end
