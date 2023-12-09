class FuelStationsController < ApplicationController
  def index
    if current_user.role == "admin"
      @fuel_stations = FuelStation.all
      respond_to do |format|
        format.html
        format.csv { send_data @fuel_stations.to_csv, filename: "fuel_stations-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
      end
    end
  end
end
