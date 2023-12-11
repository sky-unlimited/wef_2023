class FuelStationsController < ApplicationController
  def index
    if current_user.role == "admin"
      @fuel_stations = FuelStation.all
      respond_to do |format|
        format.html
        format.csv { send_data @fuel_stations.to_csv, filename: "fuel_stations-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
      end
    else
      render_404
    end
  end

  def edit
    @fuel_station = FuelStation.find(params[:id])
    @airport = Airport.find(@fuel_station.airport_id)
  end

  def update
    @fuel_station = FuelStation.find(params[:id])
    @airport = Airport.find(@fuel_station.airport_id)
    if @fuel_station.update(fuel_station_params)
      @fuel_station.save_with_user(current_user, :updated)
      flash.notice = t('fuel_station.flash.update_ok')
      render "edit"
    else
     render "edit", status: :unprocessable_entity
    end 
  end

  private

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def fuel_station_params
    params.require(:fuel_station).permit(:provider, :status, :fuel_avgas_100ll, :fuel_avgas_91ul, :charging_station, :email, :phone)
  end
end
