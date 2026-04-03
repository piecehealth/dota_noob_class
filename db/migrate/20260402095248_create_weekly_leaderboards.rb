class CreateWeeklyLeaderboards < ActiveRecord::Migration[8.1]
  def change
    create_table :weekly_leaderboards do |t|
      t.date :week_start
      t.date :week_end
      t.string :metric_type
      t.string :entity_type
      t.integer :entity_id
      t.string :entity_name
      t.integer :value
      t.integer :rank
      t.integer :classroom_id
      t.integer :group_id
      t.json :details

      t.timestamps
    end

    # Indexes for efficient queries
    add_index :weekly_leaderboards, [ :week_start, :metric_type ]
    add_index :weekly_leaderboards, [ :metric_type, :entity_type, :week_start ], name: "index_weekly_leaderboards_on_metric_type_and_entity"
    add_index :weekly_leaderboards, :entity_id
    add_index :weekly_leaderboards, :classroom_id
    add_index :weekly_leaderboards, :rank
  end
end
