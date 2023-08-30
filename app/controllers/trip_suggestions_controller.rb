require 'rgeo'
require 'json'

class TripSuggestionsController < ApplicationController
  def index
    # We load the current user last trip request
    @trip_request = TripRequest.where(user_id: current_user.id).order(id: :desc).first

    # Temporary indication on fake weather
    @fake_weather = WEF_CONFIG['fake_weather']

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

    # We create the union polygon tiles for outbound and inbound date
    fly_zone_outbound = WeatherFlyzone.new(@trip_request, @trip_request.start_date)

    #TODO: Create a separate part to retrieve weather data info.
    @outbound_weather_data    = fly_zone_outbound.get_weather_data_departure_to_date
    @outbound_weather_ok      = fly_zone_outbound.weather_departure_to_date_ok?
    fly_zone_outbound_polygon = fly_zone_outbound.flyzone_polygon

    unless @trip_request.end_date.nil? || (@trip_request.start_date == @trip_request.end_date)
      fly_zone_inbound = WeatherFlyzone.new(@trip_request, @trip_request.end_date)
      @inbound_weather_data     = fly_zone_inbound.get_weather_data_departure_to_date
      @inbound_weather_ok       = fly_zone_inbound.weather_departure_to_date_ok?
      fly_zone_inbound_polygon  = fly_zone_inbound.flyzone_polygon
    else
      fly_zone_inbound_polygon  = fly_zone_outbound_polygon
      @inbound_weather_data     = fly_zone_outbound.get_weather_data_departure_to_date
      @inbound_weather_ok       = fly_zone_outbound.weather_departure_to_date_ok?
    end

    unless fly_zone_outbound_polygon.nil? || fly_zone_inbound_polygon.nil?
      destination_zone_polygon = fly_zone_outbound_polygon.intersection(fly_zone_inbound_polygon)
    end

    # Geometries in geojson for depature date and return date
    @flyzone_outbound  = RGeo::GeoJSON.encode(fly_zone_outbound_polygon).to_json
    @flyzone_inbound   = RGeo::GeoJSON.encode(fly_zone_inbound_polygon).to_json
   
    # We convert the RGeo polygon into geojson
    @destination_zone = RGeo::GeoJSON.encode(destination_zone_polygon).to_json

    # If weather on departure airport not ok for outbound or inbound flight, we display a specific page
    if  @outbound_weather_ok == false || @inbound_weather_ok  == false 
      # We load the forecast of outbound airport based on coordinates of origin tile
      weather_call_id = WeatherService::get_weather(fly_zone_outbound.origin_tile.lat_center,
                                                    fly_zone_outbound.origin_tile.lon_center)

      # We retrieve weather information from that id
      weather_data = JSON.parse(WeatherCall.find(weather_call_id).json)

      # We load the data in an array
      @weather_array = []
      hash = {}
      (0..7).each do |index|
        weather_ok = WeatherService::is_weather_ok?( current_user, weather_data["daily"][index])

        hash = { "id"           => weather_data["daily"][index]["weather"][0]["id"],
                 "description"  => weather_data["daily"][index]["weather"][0]["description"],
                 "icon"         => weather_data["daily"][index]["weather"][0]["icon"],
                 "wind_speed"   => weather_data["daily"][index]["wind_speed"].round(0),
                 "wind_deg"     => weather_data["daily"][index]["wind_deg"].round(0),
                 "weather_ok"   => weather_ok
        }
        @weather_array.push(hash)
      end
      
      # We render the bad weather specific page
      flash.notice = t('trip_suggestions.notices.bad_weather', airport: @trip_request.airport.name)
      render "bad_weather"
    end

  end
end
