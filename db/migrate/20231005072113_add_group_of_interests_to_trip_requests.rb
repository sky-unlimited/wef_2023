class AddGroupOfInterestsToTripRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_requests, :proxy_shop, :boolean, default: false
    add_column :trip_requests, :proxy_bus_station, :boolean, default: false
    add_column :trip_requests, :proxy_train_station, :boolean, default: false
    add_column :trip_requests, :proxy_hiking_path, :boolean, default: false
    add_column :trip_requests, :proxy_coastline, :boolean, default: false
    add_column :trip_requests, :proxy_fuel_plane, :boolean, default: false
    rename_column :trip_requests, :proxy_fuel, :proxy_fuel_car
  end
end
