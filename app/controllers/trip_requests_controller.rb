require 'uri'

class TripRequestsController < ApplicationController
  before_action :set_base_url, only: [:new, :create, :edit, :update]

  def new
    @trip_request = TripRequest.new
    last_request = TripRequest.where(user_id: current_user).order(id: :asc).last
    @trip_request.start_date  = Date.today
    @trip_request.end_date    = Date.today
    unless last_request.nil?
      if last_request.start_date.to_date >= Date.today
        @trip_request.start_date = last_request.start_date
        @trip_request.end_date = last_request.end_date
      end
      @trip_request.trip_mode             = last_request.trip_mode
      @trip_request.airport_id            = last_request.airport_id
      @trip_request.international_flight  = last_request.international_flight
      @trip_request.small_airport         = last_request.small_airport
      @trip_request.medium_airport        = last_request.medium_airport
      @trip_request.large_airport         = last_request.large_airport
      @trip_request.proxy_food            = last_request.proxy_food
      @trip_request.proxy_beverage        = last_request.proxy_beverage
      @trip_request.proxy_fuel_car        = last_request.proxy_fuel_car
      @trip_request.proxy_car_rental      = last_request.proxy_car_rental
      @trip_request.proxy_bike_rental     = last_request.proxy_bike_rental
      @trip_request.proxy_camp_site       = last_request.proxy_camp_site
      @trip_request.proxy_accommodation   = last_request.proxy_accommodation
      @trip_request.proxy_shop            = last_request.proxy_shop
      @trip_request.proxy_bus_station     = last_request.proxy_bus_station
      @trip_request.proxy_train_station   = last_request.proxy_train_station
      @trip_request.proxy_hiking_path     = last_request.proxy_hiking_path
      @trip_request.proxy_coastline       = last_request.proxy_coastline
      @trip_request.proxy_lake            = last_request.proxy_lake
    end

    @trip_request.user_id = current_user.id
    set_airport_details unless @trip_request.airport_id.nil?
  end

  def create
    @trip_request = TripRequest.new(trip_request_params)
    @trip_request.trip_mode = 0

    if @trip_request.save
      redirect_to trip_suggestions_path
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
    params.require(:trip_request).permit(:user_id, :airport_id, :start_date, :end_date, :international_flight, :small_airport, :medium_airport, :large_airport, :trip_mode, :proxy_food, :proxy_beverage, :proxy_fuel_car, :proxy_fuel_plane, :proxy_car_rental, :proxy_bike_rental, :proxy_camp_site, :proxy_accommodation, :proxy_shop, :proxy_bus_station, :proxy_train_station, :proxy_hiking_path, :proxy_coastline, :proxy_lake)
  end

end
