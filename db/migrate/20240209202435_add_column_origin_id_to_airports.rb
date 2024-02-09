class AddColumnOriginIdToAirports < ActiveRecord::Migration[7.1]
  def change
    add_column :airports, :ourairports_id, :bigint, default: -1
  end
end
