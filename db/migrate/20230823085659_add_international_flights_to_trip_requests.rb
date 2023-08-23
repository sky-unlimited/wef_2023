class AddInternationalFlightsToTripRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_requests, :international_flight, :boolean, default: false
  end
end
