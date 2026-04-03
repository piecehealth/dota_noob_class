class AddRankFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :current_rank, :integer, default: 0, comment: "Current rank value from Stratz"
    add_column :users, :highest_rank, :integer, default: 0, comment: "Highest rank achieved"
    add_column :users, :total_matches, :integer, default: 0
    add_column :users, :total_wins, :integer, default: 0
    add_column :users, :rank_updated_at, :datetime

    add_index :users, :current_rank
    add_index :users, :rank_updated_at
  end
end
