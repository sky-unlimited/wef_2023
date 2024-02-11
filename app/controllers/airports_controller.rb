require 'rgeo'
require 'rgeo/proj4'
require 'rgeo-geojson'
require 'uri'

# Manages the airports used in the web app
class AirportsController < ApplicationController
  before_action :set_base_url, only: [:show]

  # GET /airports
  def index
    @airports = Airport.all.where(actif: true)
  end

  # GET /airports/1
  def show
    @airport = Airport.find(params[:id])
    fuel_station = FuelStation.find_by(airport_id: @airport.id)
    fuel_station_id = fuel_station.id unless fuel_station.nil?
    @runways = @airport.runways
    @audit_log_fuel_station = AuditLog.where(target_controller: 0)
                                      .and(AuditLog.where(
                                        target_id: fuel_station_id)).last

    # Link to Visual Airport Chart if available
    # France icao
    if @airport.icao.match?(/^LF..$/) # VAC only for ICAO airports
      # https://en.wikipedia.org/wiki/Aeronautical_Information_Publication
      airac_cycle = AiracCycle.new
      @vac_link = "https://www.sia.aviation-civile.gouv.fr/dvd/eAIP_#{airac_cycle.convert_to_sia_format}/Atlas-VAC/PDF_AIPparSSection/VAC/AD/AD-2.#{@airport.icao}.pdf"
    end
    # France baseulm (ultralight airfields)
    if !@airport.local_code.nil? && @airport.local_code.match?(/^LF....$/)
      @vac_link = "https://basulm.ffplum.fr/PDF/#{@airport.local_code}.pdf"
    end

    # Load the osm_points
    @points_array = []
    osm_points = OsmPoint.where(airport_id: @airport.id)
    osm_points.each do |osm_point|
      # Convert projection to geography
      geography   = RGeo::CoordSys::Proj4.create(4326)
      projection  = RGeo::CoordSys::Proj4.create(3857)
      x, y = RGeo::CoordSys::Proj4.transform_coords(projection,
                                                    geography,
                                                    osm_point.way.x,
                                                    osm_point.way.y, nil)

      point = {  id: osm_point.id,
                 osm_id: osm_point.osm_id,
                 name: osm_point.osm_name,
                 latitude: y,
                 longitude: x,
                 amenity: osm_point.amenity,
                 category: osm_point.category,
                 tags: PoiCatalogue.get_relevant_poi_tags(osm_point),
                 icon_url: helpers.image_url(get_icon(osm_point.amenity,
                                                      osm_point.category)) }
      @points_array << point
    end

    # Load osm_polygons but represented as points based on centroid
    @polygones_array = []
    osm_polygones = OsmPolygone.where(airport_id: @airport.id)
    osm_polygones.each do |osm_polygone|
      # We first deduct the centroid of thr polygone in order to
      #   display it as a marker
      polygone_centroid = osm_polygone.way.centroid

      # Convert projection to geography
      geography   = RGeo::CoordSys::Proj4.create(4326)
      projection  = RGeo::CoordSys::Proj4.create(3857)
      x, y = RGeo::CoordSys::Proj4.transform_coords(projection, geography,
                                                    polygone_centroid.x,
                                                    polygone_centroid.y, nil)

      point = { id: osm_polygone.id,
                osm_id: osm_polygone.osm_id,
                name: osm_polygone.osm_name,
                latitude: y,
                longitude: x,
                amenity: osm_polygone.amenity,
                category: osm_polygone.category,
                tags: PoiCatalogue.get_relevant_poi_tags(osm_polygone),
                icon_url: helpers.image_url(get_icon(osm_polygone.amenity,
                                                     osm_polygone.category)) }
      @points_array << point
    end

    # All Airports to be displayed on map
    airports = Airport.all.where(actif: true)
    # We take out the airport we display
    airports = airports.reject { |airport| airport == @airport }
    @airports_map = []
    airports.each do |airport|
      case airport.airport_type
      when 'small_airport'
        icon_url = 'small_airport.png'
      when 'medium_airport'
        icon_url = 'medium_airport.png'
      when 'large_airport'
        icon_url = 'large_airport.png'
      end
      @airports_map.push({ id: airport.id,
                           name: airport.name,
                           icao: airport.icao,
                           airport_type: airport.airport_type,
                           geojson: RGeo::GeoJSON.encode(airport.lonlat),
                           icon_url: helpers.image_url(icon_url),
                           detail_link: "#{@base_url}/#{I18n.default_locale}/
                                        airports/#{airport.id}" })
    end

    # Load weather forecast of the airport
    # @weather_airport_array = WeatherService.forecast(current_user, @airport)
    lat = @airport.latitude
    lon = @airport.longitude
    forecast_hash = Weather
                    .read(WeatherTile.coordinates_to_tile_center(
                      lat, lon
                    )[:latitude],
                          WeatherTile.coordinates_to_tile_center(
                            lat, lon
                          )[:longitude])

    # Add a tag  indiciating if weather condition compliant with
    #    pilot preferences
    pilot_pref = PilotPref.find_by(user: current_user)
    @forecast_hash  = pilot_pref.enrich_weather_forecast(forecast_hash)
    @wind_limit     = pilot_pref.max_gnd_wind_speed
  end

  private

  def set_base_url
    url = request.url
    uri = URI.parse(url)
    @base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end

  def get_icon(amenity, category)
    group = PoiCatalogue.get_group_from_amenity_and_category(amenity, category)
    PoiCatalogue.inventory[group.to_sym][:icon]
  end
end
