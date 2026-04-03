class DropCoachingRequestsAndComments < ActiveRecord::Migration[8.1]
  def up
    drop_table :comments if table_exists?(:comments)
    drop_table :coaching_request_events if table_exists?(:coaching_request_events)
    drop_table :coaching_requests if table_exists?(:coaching_requests)
  end

  def down
    create_table :coaching_requests do |t|
      t.integer :coach_id
      t.datetime :created_at, null: false
      t.integer :match_id, null: false
      t.integer :status, default: 0, null: false
      t.integer :student_id, null: false
      t.datetime :updated_at, null: false
      t.index :coach_id
      t.index :match_id, unique: true
      t.index :student_id
    end

    create_table :coaching_request_events do |t|
      t.integer :coaching_request_id, null: false
      t.datetime :created_at, null: false
      t.integer :from_status, null: false
      t.integer :operator_id, null: false
      t.integer :to_status, null: false
      t.datetime :updated_at, null: false
      t.index :coaching_request_id
      t.index :operator_id
    end

    create_table :comments do |t|
      t.integer :coaching_request_id, null: false
      t.datetime :created_at, null: false
      t.text :content
      t.datetime :updated_at, null: false
      t.integer :user_id, null: false
      t.index :coaching_request_id
      t.index :user_id
    end
  end
end
