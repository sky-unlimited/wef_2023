class FuelStationsController < ApplicationController
  after_action :audit_log, only: [ :create, :update ]

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

  def new
    @fuel_station = FuelStation.new
    @airport = Airport.find(params[:airport_id])
    @fuel_station.airport_id = @airport.id
  end

  def create
    @fuel_station = FuelStation.new(fuel_station_params)
    @airport = Airport.find(@fuel_station.airport_id)
    if @fuel_station.save
      redirect_to airport_path(@fuel_station.airport_id)
    else
      render :new, status: :unprocessable_entity
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
      flash.notice = t('fuel_station.flash.update_ok')
      redirect_to airport_path(@airport)
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
    params.require(:fuel_station).permit(:airport_id, :provider, :status, :fuel_avgas_100ll, :fuel_avgas_91ul, :fuel_mogas, :charging_station, :email, :phone)
  end
end
