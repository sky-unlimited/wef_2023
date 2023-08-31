require 'rgeo'
require 'rgeo/geos'

class Destinations

  attr_reader  :airports_matching_criterias, :airports_flyzone_common,
               :flyzone_outbound, :flyzone_inbound, :flyzone_common_polygon

  def initialize(trip_request)
    @trip_request = trip_request
    @flyzone_outbound = nil
    @flyzone_inbound = nil
    @flyzone_common_polygon = nil
    @airports_matching_criterias = []
    @airports_flyzone_common = []
    @airports_top_destinations = []

    create_flyzones
    get_airports_flyzone_common
    get_airports_matching_criterias

  end

  private

  def create_flyzones
    @flyzone_outbound =  WeatherFlyzone.new(@trip_request, @trip_request.start_date)
    unless @trip_request.end_date.nil? || (@trip_request.start_date == @trip_request.end_date)
      @flyzone_inbound =   WeatherFlyzone.new(@trip_request, @trip_request.end_date)
    else
      @flyzone_inbound = @flyzone_outbound
    end

    unless @flyzone_outbound.polygon.nil? || @flyzone_inbound.polygon.nil?
      @flyzone_common_polygon = @flyzone_outbound.polygon.intersection(@flyzone_inbound.polygon)
    end
  end

  def get_airports_flyzone_common
    # All airports inside the flyzone_common_polygon
    flyzone_airports = Airport.where("ST_Within(lonlat::geometry, ?::geometry)", @flyzone_common_polygon)

    # We apply the trip_request preferences on airport_type
    # Build an array of selected airport types
    selected_airport_types = []
    selected_airport_types << "small_airport"   if @trip_request.small_airport
    selected_airport_types << "medium_airport"  if @trip_request.medium_airport
    selected_airport_types << "large_airport"   if @trip_request.large_airport
    flyzone_airports = flyzone_airports.where(airport_type: selected_airport_types)

    # We filter also if destinations airports are outside departure country or not
    unless @trip_request.international_flight
      flyzone_airports = flyzone_airports.where(country_id: @trip_request.airport.country_id)
    end

    # We take into account the points of interest
    poi_all = []
    poi_food_items = ['restaurant', 'fast_food'] if @trip_request.proxy_food
    poi_all += poi_food_items

    # We filter the osm tables with filtered airports and poi's
    osm_points_airports    =  OsmPoint.where(airport_id: flyzone_airports)
                              .and(OsmPoint.where(amenity: poi_all))
                              .pluck(:airport_id)

    osm_lines_airports     =  OsmLine.where(airport_id: flyzone_airports)
                              .and(OsmLine.where(amenity: poi_all))
                              .pluck(:airport_id)
    osm_polygones_airports =  OsmPolygone.where(airport_id: flyzone_airports)
                              .and(OsmPolygone.where(amenity: poi_all))
                              .pluck(:airport_id)

    # We insert all airports in a single array
    airports_array = []
    airports_array += osm_points_airports + osm_lines_airports + osm_polygones_airports
    airports_array = airports_array.uniq

    # We delete of course the departure airport as it can't be a destination
    airports_array.delete_if { |value| value == @trip_request.airport_id }

    # We create an Airport object in order to retrieve all information
    airports = Airport.find(airports_array)

    # We convert the activerecords into an array
    airports.each do |airport|
    @airports_flyzone_common.push({ :name => airport.name,
                                    :icao => airport.icao,
                                    :airport_type => airport.airport_type,
                                    :geojson => RGeo::GeoJSON.encode(airport.lonlat)
    })
    end
  end

  def get_airports_matching_criterias
    # We load all airports markers
    airports = Airport.all
    airports.each do |airport|
      @airports_matching_criterias.push({ :name => airport.name,
                                          :icao => airport.icao,
                                          :airport_type => airport.airport_type,
                                          :geojson => RGeo::GeoJSON.encode(airport.lonlat)
      })
    end
  end
end
