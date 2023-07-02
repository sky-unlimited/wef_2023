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
    fly_zone_outbound = WeatherTiles.new(current_user, 
                                         Airport.find(@trip_request.airport_id), 
                                         @trip_request.start_date, 
                                         nil)

    @outbound_weather_data = fly_zone_outbound.weather_data_to_date
    @outbound_weather_ok   = fly_zone_outbound.weather_ok_to_date
    fly_zone_outbound      = fly_zone_outbound.flyzone_polygon

    unless @trip_request.end_date.nil?
      fly_zone_inbound = WeatherTiles.new(current_user, 
                                          Airport.find(@trip_request.airport_id), 
                                          @trip_request.end_date, 
                                          nil)
      @inbound_weather_data = fly_zone_inbound.weather_data_to_date
      @inbound_weather_ok   = fly_zone_inbound.weather_ok_to_date
      fly_zone_inbound      = fly_zone_inbound.flyzone_polygon
    end
    
    # We reate now the intersection between both weathers to define a fly zone that is ok
    # either for departure date as return date
    unless fly_zone_outbound.nil?  # If bad weather on departure, to polygon is created
      if fly_zone_inbound.nil?
        fly_zone_combined = fly_zone_outbound
      else
        unless fly_zone_inbound.nil?
          fly_zone_combined = fly_zone_outbound.intersection(fly_zone_inbound)
        end
      end
    end

    # Geometries in geojson for depature date and return date
    @flyzone_outbound  = RGeo::GeoJSON.encode(fly_zone_outbound).to_json
    @flyzone_inbound   = RGeo::GeoJSON.encode(fly_zone_inbound).to_json
   
    # We convert the RGeo polygon into geojson
    @destination_zone = RGeo::GeoJSON.encode(fly_zone_combined).to_json

    # If weather on departure aiport not ok, we display a specific page
    if  @outbound_weather_ok == false ||
        @inbound_weather_ok  == false 
      render "bad_weather" 
    end

  end
end
