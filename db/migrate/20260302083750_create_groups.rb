class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.references :classroom, null: false, foreign_key: true
      t.integer :number, null: false

      t.timestamps
    end
  end
end
