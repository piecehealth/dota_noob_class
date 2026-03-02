class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :display_name, null: false
      t.string :username
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.references :classroom, null: true, foreign_key: true
      t.references :group, null: true, foreign_key: true
      t.string :dota2_player_id
      t.string :activation_token, null: false
      t.datetime :activated_at

      t.timestamps
    end

    add_index :users, :username, unique: true, where: "username IS NOT NULL"
    add_index :users, :activation_token, unique: true
  end
end
