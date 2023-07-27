class ChangeWayDataTypeInOsmPolygones < ActiveRecord::Migration[7.0]
  def change
    change_column :osm_polygones, :way, :geometry, type: "st_polygon", srid: 3857
  end
end
