class CreateCoachingRequestEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :coaching_request_events do |t|
      t.references :coaching_request, null: false, foreign_key: true
      t.references :operator, null: false, foreign_key: { to_table: :users }
      t.integer :from_status, null: false
      t.integer :to_status, null: false

      t.timestamps
    end
  end
end
