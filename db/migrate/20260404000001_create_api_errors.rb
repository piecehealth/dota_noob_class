class CreateApiErrors < ActiveRecord::Migration[8.1]
  def change
    create_table :api_errors do |t|
      t.string :api_name, null: false
      t.string :error_type
      t.text :error_message
      t.string :steam_id
      t.integer :user_id
      t.string :context
      t.timestamps
    end
    
    add_index :api_errors, :created_at
    add_index :api_errors, :api_name
  end
end
