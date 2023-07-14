require 'uri'

class TripRequestsController < ApplicationController
  before_action :set_base_url, only: [:new, :create, :edit, :update]

  def new
    @trip_request = TripRequest.new
    last_request = TripRequest.where(user_id: current_user).order(id: :asc).last
    @trip_request.start_date  = Date.today
    @trip_request.end_date    = Date.today
    unless last_request.nil?
      @trip_request.airport_id = last_request.airport_id
      if last_request.start_date.to_date >= Date.today
        @trip_request.start_date = last_request.start_date
        @trip_request.end_date = last_request.end_date
      end
    end

    @trip_request.user_id = current_user.id
    set_airport_details unless @trip_request.airport_id.nil?
  end

  def create
    @trip_request = TripRequest.new(trip_request_params)

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
    params.require(:trip_request).permit(:user_id, :airport_id, :start_date, :end_date, :trip_mode, :proxy_food, :proxy_fuel, :proxy_car_rental, :proxy_bike_rental, :proxy_camp_site, :proxy_hotel)
  end

end
