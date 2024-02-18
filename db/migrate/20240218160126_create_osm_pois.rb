# This model will manage ll amenities near airprots
#   We'll try to use 'geom_point' as much as possible, even if origin object
#   in openstreetmap is a line or a polygon.
class CreateOsmPois < ActiveRecord::Migration[7.1]
  def change
    create_table :osm_pois do |t|
      t.bigint :osm_id, null: false
      t.string :osm_name
      t.string :amenity, null: false
      t.string :tags, null: false
      t.st_point :geom_point, srid: 3857
      t.line_string :geom_line, srid: 3857
      t.st_polygon :geom_polygon, srid: 3857
      t.integer :distance
      t.references :airport, null: false, foreign_key: true, index: true

      t.timestamps

      # Optionally, you can add a spatial index for the new column
      #add_index :osm_pois, :geom_point, using: :gist
    end
  end
end
