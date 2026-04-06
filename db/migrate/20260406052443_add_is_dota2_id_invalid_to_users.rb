class AddIsDota2IdInvalidToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :is_dota2_id_invalid, :boolean, default: false, null: false
  end
end
