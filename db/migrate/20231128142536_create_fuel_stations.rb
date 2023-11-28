class CreateFuelStations < ActiveRecord::Migration[7.0]
  def change
    create_table :fuel_stations do |t|
      t.references :airport, null: false, foreign_key: true
      t.integer :provider, null: false
      t.integer :status, null: false
      t.boolean :fuel_avgas_100ll
      t.boolean :fuel_avgas_91ul
      t.boolean :fuel_mogas
      t.boolean :charging_station
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
