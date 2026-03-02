class CreateClassrooms < ActiveRecord::Migration[8.1]
  def change
    create_table :classrooms do |t|
      t.string :name
      t.integer :number, null: false

      t.timestamps
    end

    add_index :classrooms, :number, unique: true
  end
end
