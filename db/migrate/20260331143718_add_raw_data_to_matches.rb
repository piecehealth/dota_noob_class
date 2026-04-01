class AddRawDataToMatches < ActiveRecord::Migration[8.1]
  def change
    add_column :matches, :raw_data, :json
  end
end
