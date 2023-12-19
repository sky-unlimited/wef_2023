class ChangeTripRequestsFuelServices < ActiveRecord::Migration[7.0]
  def change
    rename_column :trip_requests, :proxy_fuel_plane,    :fuel_station_100ll
    add_column    :trip_requests, :fuel_station_91ul,   :boolean, default: false
    add_column    :trip_requests, :fuel_station_mogas,  :boolean, default: false
    add_column    :trip_requests, :charging_station,    :boolean, default: false
  end
end
