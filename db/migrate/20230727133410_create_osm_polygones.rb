class CreateOsmPolygones < ActiveRecord::Migration[7.0]
  def change
    create_table :osm_polygones do |t|
      t.integer :osm_id, null: false, :limit => 8
      t.string :osm_name
      t.string :amenity, null: false
      t.string :tags
      t.string :category
      t.geography :way, type: "st_point", srid: 3857 #4326
      t.float :distance
      t.integer :airport_id

      t.timestamps
    end
  end
end
