class UpdateAirports < ActiveRecord::Migration[7.1]
  def change
    remove_column :airports, :ourairports_id, :bigint
    add_column :airports, :geom_polygon, :geometry, limit: {:srid=>3857, :type=>"polygon"}
    rename_column :airports, :lonlat, :geom_point
    remove_column :runways, :internal_id, :bigint
  end
end
