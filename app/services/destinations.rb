require 'rgeo'
require 'rgeo/geos'

class Destinations

  attr_reader  :airports_matching_criterias, :airports_flyzone_common,
               :flyzone_outbound, :flyzone_inbound, :flyzone_common_polygons

  def initialize(trip_request)
    @trip_request = trip_request
    @flyzone_outbound = nil
    @flyzone_inbound = nil
    @flyzone_common_polygons = nil
    @airports_matching_criterias = []
    @airports_flyzone_common = []
    @airports_top_destinations = []

    create_flyzones
    # If no flyzones -> no flight -> no destinations
    unless @flyzone_outbound.polygon.nil? || @flyzone_inbound.polygon.nil?
      get_airports_flyzone_common
      get_airports_matching_criterias
    end
  end

  private

  # This method will create if weather conditions ok on outbound and inbound
  #   - flyzone_outbound
  #   - flyzone_inbound
  #   - flyzone_common_polygons
  def create_flyzones
    @flyzone_outbound =  WeatherFlyzone.new(@trip_request, @trip_request.start_date)
    unless @trip_request.end_date.nil? || (@trip_request.start_date == @trip_request.end_date)
      @flyzone_inbound =   WeatherFlyzone.new(@trip_request, @trip_request.end_date)
    else
      # same dates so same flyzone
      @flyzone_inbound = @flyzone_outbound
    end

    # We create the common flyzone which is an intersection
    # of @flyzone_outbound and @flyzone_inbound. However, the resulting
    # geometry is no more just a POLYGON. It's mostly to be a MULTIGEOMETRY type.
    unless @flyzone_outbound.polygon.nil? || @flyzone_inbound.polygon.nil?
      flyzone_common = @flyzone_outbound.polygon.intersection(@flyzone_inbound.polygon)
      if flyzone_common.geometry_type.name == "RGeo::Feature::Polygon"
        # The geometry is a polygon, most of the case when
        # @flyzone_outbound = @flyzone_inbound
        @flyzone_common_polygons = flyzone_common
      else
        # The geometry type is a geometry collection (different kind of geometries)
        # We parse the object to keep only the POLYGON
        # Resulting object will most likely be a MULTIPOLYGON
        flyzone_common.each do |geometry|
          if geometry.geometry_type.name == "RGeo::Feature::Polygon"
            if @flyzone_common_polygons.nil?
              @flyzone_common_polygons = geometry
            else
              @flyzone_common_polygons = @flyzone_common_polygons.union(geometry)
            end
          end
        end
      end
    end
  end

  def get_airports_flyzone_common
    # All airports inside the flyzone_common_polygon
    # Approach is different whether @flyzone_common_polygons has a
    # geometry_type POLYGON or MULTIPOLYGON
    if @flyzone_common_polygons.geometry_type.name == "RGeo::Feature::Polygon"
      flyzone_airports = Airport.where("ST_Within(lonlat::geometry, ?::geometry)", @flyzone_common_polygons)
    else
      # We need to iterate on each POLYGON included in MULTIPOLYGON
      airports_array = nil
      @flyzone_common_polygons.each do |polygon|
        if airports_array.nil?
          airports_array = Airport.where("ST_Within(lonlat::geometry, ?::geometry)", polygon).pluck(:id)
        else
          airports_array += Airport.where("ST_Within(lonlat::geometry, ?::geometry)", polygon).pluck(:id)
        end
      end
      # We convert the airports_array into an activerecord_relation
      flyzone_airports = Airport.where(id: airports_array)
    end

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
    poi_all += poi_food_items unless poi_food_items.nil?

    # We filter the osm tables with filtered airports and poi's
    osm_points_airports     = []
    osm_lines_airports      = []
    osm_polygones_airports  = []

    osm_points_airports     =  OsmPoint.where(airport_id: flyzone_airports)
                              .and(OsmPoint.where(amenity: poi_all))
                              .pluck(:airport_id)
    osm_lines_airports      =  OsmLine.where(airport_id: flyzone_airports)
                              .and(OsmLine.where(amenity: poi_all))
                              .pluck(:airport_id)
    osm_polygones_airports  =  OsmPolygone.where(airport_id: flyzone_airports)
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

    # We convert the activerecords into an array with format required for map display
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
