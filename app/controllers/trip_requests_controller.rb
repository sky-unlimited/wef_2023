require 'uri'

class TripRequestsController < ApplicationController
  before_action :set_base_url, only: [:new, :create, :edit, :update]

  def new
    @trip_request = TripRequest.new
    @trip_request.user = current_user
    @trip_request.airport_id = params[:airport].to_i
    set_airport_details if @trip_request.airport_id.positive?
  end

  def create
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

end
