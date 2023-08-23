class AddAirportTypesToTripRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_requests, :small_airport, :boolean, default: false
    add_column :trip_requests, :medium_airport, :boolean, default: true
    add_column :trip_requests, :large_airport, :boolean, default: false
  end
end
