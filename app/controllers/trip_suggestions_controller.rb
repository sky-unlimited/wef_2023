require 'rgeo'

class TripSuggestionsController < ApplicationController
  def index
    # We load the current user last trip request
    @trip_request = TripRequest.where(user_id: current_user.id).order(id: :desc).first

    # We load all airports markers
    @airports_array = []
    airports = Airport.all
    airports.each do |airport|
      @airports_array.push({ :name => airport.name,
                            :icao => airport.icao,
                            :airport_type => airport.airport_type,
                            :geojson => RGeo::GeoJSON.encode(airport.lonlat)
      })
    end

    # We create the union polygons fly-zone for departure and return date
    fly_zone_departure_date = WeatherTiles.new(current_user, 
                                               Airport.find(@trip_request.airport_id), 
                                               @trip_request.start_date, 
                                               nil)

    @departure_weather_data = fly_zone_departure_date.weather_data_to_date
    @departure_weather_ok   = fly_zone_departure_date.weather_ok_to_date
    fly_zone_departure      = fly_zone_departure_date.flyzone_polygon

    unless @trip_request.end_date.nil?
      fly_zone_return_date = WeatherTiles.new(current_user, 
                                               Airport.find(@trip_request.airport_id), 
                                               @trip_request.end_date, 
                                               nil)
      @return_weather_data  = fly_zone_return_date.weather_data_to_date
      @return_weather_ok    = fly_zone_return_date.weather_ok_to_date
      fly_zone_return       = fly_zone_return_date.flyzone_polygon
    end
    
    # We reate now the intersection between both weathers to define a fly zone that is ok
    # either for departure date as return date
    unless fly_zone_departure.nil?  # If bad weather on departure, to polygon is created
      if fly_zone_return_date.nil?
        fly_zone_combined = fly_zone_departure
      else
        unless fly_zone_return.nil?
          fly_zone_combined = fly_zone_departure.intersection(fly_zone_return)
        end
      end
    end

    # We convert the RGeo polygon into geojson
    @flyzone = RGeo::GeoJSON.encode(fly_zone_combined).to_json

    # If weather on departure aiport not ok, we display a specific page
    if  fly_zone_departure_date.weather_ok_to_date == false ||
        fly_zone_return_date.weather_ok_to_date == false 
      render "bad_weather" 
    end

  end
end
