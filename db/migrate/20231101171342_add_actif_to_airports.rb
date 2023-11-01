class AddActifToAirports < ActiveRecord::Migration[7.0]
  def change
    add_column :airports, :actif, :boolean, default: true
  end
end
