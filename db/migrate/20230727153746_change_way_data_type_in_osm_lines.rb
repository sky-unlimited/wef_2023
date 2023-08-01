class ChangeWayDataTypeInOsmLines < ActiveRecord::Migration[7.0]
  def change
    change_column :osm_lines, :way, :geometry, type: "line_string", srid: 3857
  end
end
