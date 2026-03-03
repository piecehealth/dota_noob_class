class CreateCoachingRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :coaching_requests do |t|
      t.references :match, null: false, foreign_key: true, index: { unique: true }
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :coach, null: true, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_check_constraint :coaching_requests, "status IN (0, 1, 2)", name: "coaching_requests_status_check"
  end
end
