class AddGroupOfInterests2ToTripRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_requests, :proxy_beverage, :boolean, default: false
    rename_column :trip_requests, :proxy_hotel, :proxy_accommodation
  end
end
