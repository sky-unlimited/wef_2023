require 'uri'

class TripRequestsController < ApplicationController
  before_action :set_base_url, only: [:new, :create, :edit, :update]

  def new
    @trip_request = TripRequest.new
    @trip_request.user_id = current_user.id
    @trip_request.airport_id = params[:airport].to_i
    set_airport_details if @trip_request.airport_id.positive?
  end

  def create
    @trip_request = TripRequest.new(trip_request_params)

    if @trip_request.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  private

  def set_base_url
    url = request.url
    uri = URI.parse(url)
    @base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end

  def set_airport_details
    airport = Airport.find(@trip_request.airport_id)
    airport_name = airport.name
    airport_icao = airport.icao
    @airport_full_name = "#{airport_name} (#{airport_icao})"
  end

  def trip_request_params
    params.require(:trip_request).permit(:user_id, :airport_id, :start_date, :end_date, :trip_mode, :proxy_food, :proxy_fuel, :proxy_car_rental, :proxy_bike_rental, :proxy_camp_site, :proxy_hotel)
  end

end
