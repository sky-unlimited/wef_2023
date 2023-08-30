require 'rgeo'
require 'json'

class TripSuggestionsController < ApplicationController
  def index
    # We load the current user last trip request
    @trip_request = TripRequest.where(user_id: current_user.id).order(id: :desc).first

    # Instantiating Destinations class
    destinations = Destinations.new(@trip_request)

    # Temporary indication on fake weather for display purpose
    @fake_weather = WEF_CONFIG['fake_weather']

    # Geometries in geojson for depature date and return date for display purpose
    @flyzone_outbound       = RGeo::GeoJSON.encode(destinations.flyzone_outbound.polygon).to_json
    @flyzone_inbound        = RGeo::GeoJSON.encode(destinations.flyzone_inbound.polygon).to_json
    @flyzone_common_polygon = RGeo::GeoJSON.encode(destinations.flyzone_common_polygon).to_json

    # We load airports with matching criterias for display purpose
    @airports_array = destinations.airports_matching_criterias

    # We load weather for outbound and inbound for display purpose
    @outbound_weather_data  = destinations.flyzone_outbound.get_weather_data_departure_to_date
    @outbound_weather_ok    = destinations.flyzone_outbound.weather_departure_to_date_ok?
    @inbound_weather_data   = destinations.flyzone_inbound.get_weather_data_departure_to_date
    @inbound_weather_ok     = destinations.flyzone_inbound.weather_departure_to_date_ok?

    # If weather on departure airport not ok for outbound or inbound flight, we display a specific page
    if  destinations.flyzone_outbound.weather_departure_to_date_ok?  == false || 
        destinations.flyzone_inbound.weather_departure_to_date_ok? == false 
      # We load the forecast of outbound airport based on coordinates of origin tile
      weather_call_id = WeatherService::get_weather(destinations.flyzone_outbound.origin_tile.lat_center,
                                                    destinations.flyzone_outbound.origin_tile.lon_center)

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
