require 'rgeo'
require 'rgeo/geos'

class Destinations

  attr_reader  :airports_matching_criterias, :airports_flyzone,
               :flyzone_outbound, :flyzone_inbound, :flyzone_common_polygons,
               :top_destinations

  def initialize(trip_request)
    @trip_request = trip_request
    @flyzone_outbound = nil
    @flyzone_inbound = nil
    @flyzone_common_polygons = nil
    @airports_matching_criterias = []
    @airports_flyzone = []
    @top_destinations = []

    create_flyzones
    get_airports_matching_criterias
    # If no flyzones -> no flight -> no destinations
    unless @flyzone_outbound.polygon.nil? || @flyzone_inbound.polygon.nil?
      get_airports_flyzone
      get_top_destinations
    end
  end

  private

  # This method will create if weather conditions ok on outbound and inbound:
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

  def get_airports_matching_criterias
    # Filter per users's selected poi's
    airports_matching_criterias = PoiCatalogue.airports_matching_pois(@trip_request)

    # Apply the trip_request preferences on airport_type
    selected_airport_types = []
    selected_airport_types << "small_airport"   if @trip_request.small_airport
    selected_airport_types << "medium_airport"  if @trip_request.medium_airport
    selected_airport_types << "large_airport"   if @trip_request.large_airport

    # Filter airports by selected airport types
    airports_matching_criterias = airports_matching_criterias.where(airport_type: selected_airport_types)

    # Filter airports by runway length
    airports_matching_criterias = airports_matching_criterias.joins(:runways)
      .where('runways.length_meter >= ?', @trip_request.user.pilot_pref.min_runway_length).distinct

    # Filter airports for PPL only
    airports_matching_criterias = airports_matching_criterias.where('length(icao) = 4') if @trip_request.user.pilot_pref.is_ultralight_pilot == false
 
    # Filter airports based on international flight preference
    unless @trip_request.international_flight
      airports_matching_criterias = airports_matching_criterias.where(country_id: @trip_request.airport.country_id)
    end

    # Exclude the departure airport from the list of matching airports
    airports_matching_criterias = airports_matching_criterias.where.not(id: @trip_request.airport.id)

    # We create an Airport object in order to retrieve all information
    @airports_matching_criterias = airports_matching_criterias
  end

  def get_airports_flyzone
    # All airports inside the flyzone_common_polygon
    # Approach is different whether @flyzone_common_polygons has a
    # geometry_type POLYGON or MULTIPOLYGON
    if @flyzone_common_polygons.geometry_type.name == "RGeo::Feature::Polygon"
      @airports_flyzone = @airports_matching_criterias.where("ST_Within(lonlat::geometry, ?::geometry)", @flyzone_common_polygons)
    else
      # We need to iterate on each POLYGON included in MULTIPOLYGON
      airports_array = nil
      @flyzone_common_polygons.each do |polygon|
        if airports_array.nil?
          airports_array = @airports_matching_criterias.where("ST_Within(lonlat::geometry, ?::geometry)", polygon).pluck(:id)
        else
          airports_array += @airports_matching_criterias.where("ST_Within(lonlat::geometry, ?::geometry)", polygon).pluck(:id)
        end
      end
      # We convert the airports_array into an activerecord_relation
      @airports_flyzone = Airport.where(id: airports_array)
    end
  end

  def get_top_destinations
    #TODO: Of course, the algo needs further analysis. Issue github to come
    destinations = []

    @airports_flyzone.each do |airport|
      flight_track = FlightTrack.new( @trip_request.airport.lonlat, 
                                    airport.lonlat,
                                    @trip_request.user.pilot_pref.average_true_airspeed,
                                    @flyzone_common_polygons)

      # Priority 1: Direct Flight
      direct_flight = flight_track.is_in_flyzone ? 1 : 0

      # Priority 2: Distance categories
      distance_category =
        if flight_track.average_flight_time_min < 120
          "Flight Time < 120 mins"
        elsif flight_track.average_flight_time_min < 180
          "Flight Time < 180 mins"
        else
          "Flight Time > 180 mins"
        end

      # Priority 3: Heading groups
      heading_category =
        case flight_track.bearing
        when 0..90
          "NE Heading"
        when 91..180
          "SE Heading"
        when 181..270
          "SW Heading"
        else
          "NW Heading"
        end

      destinations << { :airport        => airport,
                        :flight_track   => flight_track,
                        :direct_flight  => direct_flight,
                        :distance_group => distance_category,
                        :heading_group  => heading_category }
    end

    # Filtering rules
    # 1. Flight Time more than 30 minutes
    filtered_destinations = destinations.select { 
      |destination| destination[:flight_track].average_flight_time_min >= 30 }
    
    # Sorting rules:
    # 1.  We first sort records by prioritizing direct flights. It means destinations
    #     for which the flight track is 100% within the flyzone (good weather zone)
    # 2. The distance from departure airport
    sorted_destinations = filtered_destinations.sort_by do |destination|
      flight_track = destination[:flight_track]
      # rule 1
      is_in_flyzone = flight_track.is_in_flyzone ? 0 : 1
      # rule 2
      distance = flight_track.distance_km

      [is_in_flyzone, distance]
    end
    @top_destinations = sorted_destinations.first(5)

    #NOTE: %w(1 2 3 4 5 6 7 8 9 10).in_groups_of(3) {|group| p group}
    # https://www.rubydoc.info/docs/rails/Array
  end
end
