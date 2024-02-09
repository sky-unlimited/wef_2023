require 'rgeo'
require 'json'
require 'uri'

# Manages the outcome of suggested destinations
class TripSuggestionsController < ApplicationController
  before_action :set_base_url, only: [:index]

  def index
    # We load the current user last trip request
    @trip_request = TripRequest.where(user_id: current_user.id)
                               .order(id: :desc).first

    # We load the pilot preferences
    @pilot_prefs = PilotPref.find_by(user_id: @trip_request.user_id)

    # Instantiating Destinations class
    destinations = Destinations.new(@trip_request)

    # Temporary indication on fake weather for display purpose
    @fake_weather = false

    # Geometries in geojson for depature and return date for display purpose
    @flyzone_outbound = RGeo::GeoJSON
                        .encode(destinations.flyzone_outbound.polygon).to_json
    @flyzone_inbound = RGeo::GeoJSON
                       .encode(destinations.flyzone_inbound.polygon).to_json
    @flyzone_common_polygons = RGeo::GeoJSON
                               .encode(destinations.flyzone_common_polygons)
                               .to_json

    # We load departure airport information for map display
    @departure_airport = []
    hash = { name: @trip_request.airport.name,
             icao: @trip_request.airport.icao,
             airport_type: @trip_request.airport.airport_type,
             geojson: RGeo::GeoJSON.encode(@trip_request.airport.lonlat),
             icon_url: helpers.image_url('departure_airport.png') }
    @departure_airport.push(hash)

    # We load airports with matching criterias for map display purpose
    @airports_matching_criterias_map = []
    destinations.airports_matching_criterias.each do |airport|
      case airport.airport_type
      when 'small_airport'
        icon_url = 'small_airport.png'
      when 'medium_airport'
        icon_url = 'medium_airport.png'
      when 'large_airport'
        icon_url = 'large_airport.png'
      end

      link = "#{@base_url}/#{I18n.default_locale}/airports/#{airport.id}"
      hash = { id: airport.id,
               name: airport.name,
               icao: airport.icao,
               airport_type: airport.airport_type,
               geojson: RGeo::GeoJSON.encode(airport.lonlat),
               icon_url: helpers.image_url(icon_url),
               detail_link: link }
      @airports_matching_criterias_map.push(hash)
    end

    # We load flyzone airports for map display purpose
    @airports_flyzone_map = []
    destinations.airports_flyzone.each do |airport|
      case airport.airport_type
      when 'small_airport'
        icon_url = 'small_airport.png'
      when 'medium_airport'
        icon_url = 'medium_airport.png'
      when 'large_airport'
        icon_url = 'large_airport.png'
      end

      link = "#{@base_url}/#{I18n.default_locale}/airports/#{airport.id}"
      hash = { id: airport.id,
               name: airport.name,
               icao: airport.icao,
               airport_type: airport.airport_type,
               geojson: RGeo::GeoJSON.encode(airport.lonlat),
               icon_url: helpers.image_url(icon_url),
               detail_link: link }
      @airports_flyzone_map.push(hash)
    end

    # We load the destination airports in separate array to be displayed
    @weather_destination_array  = []
    @airports_destination_map   = []
    destinations.top_destination_airports.each_with_index do |dest, index|
      link = "#{@base_url}/#{I18n.default_locale}/airports/#{dest.id}"
      hash = { id: dest.id,
               name: dest.name,
               icao: dest.icao,
               airport_type: dest.airport_type,
               geojson: RGeo::GeoJSON.encode(dest.lonlat),
               icon_url: helpers.image_url("destination_#{index + 1}.png"),
               detail_link: link }
      @airports_destination_map.push(hash)
    end

    # We load the top destinations
    @top_destination_airports = destinations.top_destination_airports

    # We load the flight tracks for front-end (javascript)
    @flight_tracks = []
    @top_destination_airports.each do |airport|
      track = FlightTrack.new(@trip_request.airport.lonlat,
                              airport.lonlat,
                              @trip_request.user
                               .pilot_pref.average_true_airspeed,
                              destinations.flyzone_common_polygons)
      @flight_tracks << track
    end

    # We load weather for outbound and inbound for front-end (javascript)
    @outbound_weather_data = destinations.flyzone_outbound
                                         .origin_tile.weather_data_to_date
    @outbound_weather_ok = destinations.flyzone_outbound
                                       .origin_tile
                                       .is_weather_pilot_compliant
    @inbound_weather_data = destinations.flyzone_inbound
                                        .origin_tile
                                        .weather_data_to_date
    @inbound_weather_ok = destinations.flyzone_inbound
                                      .origin_tile
                                      .is_weather_pilot_compliant

    # If weather on departure airport not ok for outbound or inbound flight,
    # we display a specific page
    return unless @outbound_weather_ok == false || @inbound_weather_ok == false

    # Load weather for departure airport in order to retrieve the forecast
    coord_center = WeatherTile.coordinate_to_tile_center(
      @trip_request.airport.latitude,
      @trip_request.airport.longitude
    )

    forecast_hash = Weather.read(coord_center[:latitude],
                                 coord_center[:longitude])

    # Add a tag indiciating if weather condition compliant with pilot prefs
    @forecast_hash  = @pilot_prefs.enrich_weather_forecast(forecast_hash)
    @wind_limit     = @pilot_prefs.max_gnd_wind_speed

    # We render the bad weather specific page
    flash.notice = t('trip_suggestions.notices.bad_weather',
                     airport: @trip_request.airport.name)
    render 'bad_weather'
  end

  private

  def set_base_url
    url = request.url
    uri = URI.parse(url)
    @base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end
end
