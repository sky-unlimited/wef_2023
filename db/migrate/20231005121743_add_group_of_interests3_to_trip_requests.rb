class AddGroupOfInterests3ToTripRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :trip_requests, :proxy_lake, :boolean, default: false
  end
end
