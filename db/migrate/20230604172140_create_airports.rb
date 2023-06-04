class CreateAirports < ActiveRecord::Migration[7.0]
  def change
    create_table :airports do |t|
      t.string :icao, null: false
      t.string :name
      t.string :city
      t.references :country, null: false, foreign_key: true
      t.string :iata
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.integer :altitude
      t.string :dst
      t.string :airport_type, null: false
      t.string :url
      t.string :local_code
      t.geography :lonlat, limit: { srid: 4326, type: "st_point", geographic: true }

      t.timestamps
    end

    add_index :airports, :id, unique: true
  end
end
