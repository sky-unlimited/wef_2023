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
    @pilots = @airport.pilots.includes(user: :picture_attachment)
    @runways = @airport.runways
    @audit_log_fuel_station = AuditLog.where(target_controller: 0)
                                      .and(AuditLog.where(
                                             target_id: fuel_station_id
                                           )).last

    # Link to Visual Airport Chart if available
    # France icao
    if @airport.icao.match?(/^LF..$/) # VAC only for ICAO airports
      # https://en.wikipedia.org/wiki/Aeronautical_Information_Publication
      airac_cycle = AiracCycle.new
      @vac_link = 'https://www.sia.aviation-civile.gouv.fr/dvd/eAIP_' \
                  "#{airac_cycle.convert_to_sia_format}/Atlas-VAC/" \
                  "PDF_AIPparSSection/VAC/AD/AD-2.#{@airport.icao}.pdf"
    end

    # France baseulm (ultralight airfields)
    if !@airport.local_code.nil? && @airport.local_code.match?(/^LF....$/)
      @vac_link = "https://basulm.ffplum.fr/PDF/#{@airport.local_code}.pdf"
    end

    # Netherlands
    nl_eligible = %w[EHAL EHAM EHBD EHBK EHDR EHEH EHGG EHHO EHHV EHKD EHLE
                     EHMZ EHOW EHRD EHSE EHST EHTE EHTL EHTW EHTX]
    if nl_eligible.include?(@airport.icao)
      airac_cycle = AiracCycle.new
      @vac_link = 'https://eaip.lvnl.nl/web/' \
                  "#{airac_cycle.convert_to_nl_format}/html/eAIP/EH-AD-2." \
                  "#{@airport.icao}-en-GB.html#AD-2.#{@airport.icao}"
    end

    # Load the osm points of interest
    @points_array = []
    osm_pois = OsmPoi.where(airport_id: @airport.id)
    osm_pois.each do |osm_poi|
      # Exclude poi's like hiking paths
      next if osm_poi.geom_point.nil?

      # Convert projection to geography
      geography   = RGeo::CoordSys::Proj4.create(4326)
      projection  = RGeo::CoordSys::Proj4.create(3857)
      x, y = RGeo::CoordSys::Proj4.transform_coords(projection,
                                                    geography,
                                                    osm_poi.geom_point.x,
                                                    osm_poi.geom_point.y, nil)

      @points_array << {  id: osm_poi.id,
                          osm_id: osm_poi.osm_id,
                          name: osm_poi.osm_name,
                          latitude: y,
                          longitude: x,
                          amenity: osm_poi.amenity,
                          category: osm_poi.category,
                          tags: PoiCatalogue
                       .get_relevant_poi_tags(osm_poi),
                          icon_url: helpers.image_url(
                            get_icon(osm_poi.amenity,
                                     osm_poi.category)
                          ) }
    end

    # Load weather forecast of the airport
    lat = @airport.latitude
    lon = @airport.longitude
    forecast_hash = Weather
                    .read(WeatherTile.coordinates_to_tile_center(
                      lat, lon
                    )[:latitude],
                          WeatherTile.coordinates_to_tile_center(
                            lat, lon
                          )[:longitude])

    # Add a tag indiciating if weather condition compliant with
    #   pilot preferences
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
    PoiCatalogue.inventory[group]['icon']
  end
end
