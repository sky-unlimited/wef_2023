require 'rgeo'
require 'rgeo/geos'

# Manages the destinations suggestions
class Destinations
  attr_reader  :airports_matching_criterias, :airports_flyzone,
               :flyzone_outbound, :flyzone_inbound, :flyzone_common_polygons,
               :top_destination_airports

  def initialize(trip_request)
    @trip_request = trip_request
    @flyzone_outbound = nil
    @flyzone_inbound = nil
    @flyzone_common_polygons = nil
    @airports_matching_criterias = []
    @airports_flyzone = []
    @top_destination_airports = []

    init_flyzones
    init_airports_matching_criterias
    # If no flyzones -> no flight -> no destinations
    return if @flyzone_outbound.polygon.nil? || @flyzone_inbound.polygon.nil?

    init_airports_flyzone
    init_top_destination_airports
  end

  private

  # This method will create if weather conditions ok on outbound and inbound:
  #   - flyzone_outbound
  #   - flyzone_inbound
  #   - flyzone_common_polygons (the common zone inbound and outbound)
  def init_flyzones
    @flyzone_outbound = WeatherFlyzone.new(@trip_request,
                                           @trip_request.start_date)
    if  @trip_request.end_date.nil? ||
        (@trip_request.start_date == @trip_request.end_date)
      # same dates so same flyzone
      @flyzone_inbound = @flyzone_outbound
    else
      @flyzone_inbound = WeatherFlyzone.new(@trip_request,
                                            @trip_request.end_date)
    end

    # We create the common flyzone which is an intersection
    #   of @flyzone_outbound and @flyzone_inbound. However, the resulting
    #   geometry is no more just a POLYGON.
    #   It's mostly to be a MULTIGEOMETRY type.
    return if @flyzone_outbound.polygon.nil? || @flyzone_inbound.polygon.nil?

    flyzone_common =  @flyzone_outbound
                      .polygon.intersection(@flyzone_inbound.polygon)
    if flyzone_common.geometry_type.name == 'RGeo::Feature::Polygon'
      # The geometry is a polygon, most of the case when
      #   @flyzone_outbound = @flyzone_inbound
      @flyzone_common_polygons = flyzone_common
    else
      # The geometry type is a geometry collection
      #   We parse the object to keep only the POLYGON
      #   Resulting object will most likely be a MULTIPOLYGON
      flyzone_common.each do |geometry|
        next unless geometry.geometry_type.name == 'RGeo::Feature::Polygon'

        @flyzone_common_polygons = if @flyzone_common_polygons.nil?
                                     geometry
                                   else
                                     @flyzone_common_polygons.union(geometry)
                                   end
      end
    end
  end

  def init_airports_matching_criterias
    # Filter per users's selected poi's
    airports_matching_criterias_ids = PoiCatalogue
                                      .airports_matching_pois(@trip_request)

    # Filter on expected fuel services
    if @trip_request.fuel_station_100ll
      ids_100ll = FuelStation.where
                             .not(fuel_avgas_100ll: :no).pluck(:airport_id)
      if airports_matching_criterias_ids.empty?
        airports_matching_criterias_ids = ids_100ll
      else
        airports_matching_criterias_ids = airports_matching_criterias_ids
                                          .intersection(ids_100ll)
      end
    end
    if @trip_request.fuel_station_91ul
      ids_91ul = FuelStation.where.not(fuel_avgas_91ul: :no).pluck(:airport_id)
      if airports_matching_criterias_ids.empty?
        airports_matching_criterias_ids = ids_91ul
      else
        airports_matching_criterias_ids = airports_matching_criterias_ids
                                          .intersection(ids_91ul)
      end
    end
    if @trip_request.fuel_station_mogas
      ids_mogas = FuelStation.where.not(fuel_mogas: :no).pluck(:airport_id)
      if airports_matching_criterias_ids.empty?
        airports_matching_criterias_ids = ids_mogas
      else
        airports_matching_criterias_ids = airports_matching_criterias_ids
                                          .intersection(ids_mogas)
      end
    end
    if @trip_request.charging_station
      ids_charging = FuelStation.where
                                .not(charging_station: :no).pluck(:airport_id)
      if airports_matching_criterias_ids.empty?
        airports_matching_criterias_ids = ids_charging
      else
        airports_matching_criterias_ids = airports_matching_criterias_ids
                                          .intersection(ids_charging)
      end
    end

    # Load corresponding airports instances
    airports_matching_criterias = Airport
                                  .where(id: airports_matching_criterias_ids)

    # Apply the trip_request preferences on airport_type
    selected_airport_types = []
    selected_airport_types << 'small_airport'   if @trip_request.small_airport
    selected_airport_types << 'medium_airport'  if @trip_request.medium_airport
    selected_airport_types << 'large_airport'   if @trip_request.large_airport

    # Filter airports by selected airport types
    airports_matching_criterias = airports_matching_criterias
                                  .where(airport_type: selected_airport_types)

    # Filter actif airports
    airports_matching_criterias = airports_matching_criterias.where(actif: true)

    # Filter airports by runway length
    airports_matching_criterias =
      airports_matching_criterias.joins(:runways)
                                 .where('runways.length_meter >= ?',
                                        @trip_request.user
                                                     .pilot_pref
                                                     .min_runway_length)
                                 .distinct

    # Filter airports for PPL only
    if @trip_request.user.pilot_pref.is_ultralight_pilot == false
      airports_matching_criterias = airports_matching_criterias
                                    .where('length(icao) = 4')
    end

    # Filter airports based on international flight preference
    unless @trip_request.international_flight
      airports_matching_criterias = airports_matching_criterias
                                    .where(country_id: @trip_request
                                                       .airport.country_id)
    end

    # Exclude the departure airport from the list of matching airports
    airports_matching_criterias = airports_matching_criterias
                                  .where.not(id: @trip_request.airport.id)

    # Create an Airport object for viewing purpose
    @airports_matching_criterias = airports_matching_criterias
  end

  def init_airports_flyzone
    # All airports inside the flyzone_common_polygon
    # Approach is different whether @flyzone_common_polygons has a
    # geometry_type POLYGON or MULTIPOLYGON
    if @flyzone_common_polygons.geometry_type.name == 'RGeo::Feature::Polygon'
      @airports_flyzone = @airports_matching_criterias.where(
        'ST_Within(geom_point::geometry, ?::geometry)', @flyzone_common_polygons
      )
    else
      # We need to iterate on each POLYGON included in MULTIPOLYGON
      airports_array = nil
      @flyzone_common_polygons.each do |polygon|
        if airports_array.nil?
          airports_array = @airports_matching_criterias.where(
            'ST_Within(geom_point::geometry, ?::geometry)', polygon
          ).pluck(:id)
        else
          airports_array += @airports_matching_criterias.where(
            'ST_Within(geom_point::geometry, ?::geometry)', polygon
          ).pluck(:id)
        end
      end
      # We convert the airports_array into an activerecord_relation
      @airports_flyzone = Airport.where(id: airports_array)
    end
  end

  def init_top_destination_airports
    # Create the destination object having airport and flight_track classes
    destinations = []
    @airports_flyzone.each do |airport|
      flight_track = FlightTrack.new(@trip_request.airport.geom_point,
                                     airport.geom_point,
                                     @trip_request.user.pilot_pref
                                                  .average_true_airspeed,
                                     @flyzone_common_polygons)

      # Create temporary destination array
      destinations << { airport:,
                        flight_track: }
    end

    # Filtering rules
    # 1. Flight Time more than 30 minutes
    destinations.select do |destination|
      destination[:flight_track].average_flight_time_min >= 30
    end

    # Create temporary array of priority groups per airport
    airports_priority_groups = []

    destinations.each do |destination|
      # Priority 1: Direct Flight
      direct_flight = destination[:flight_track].is_in_flyzone ? 0 : 1
      # Inverted for sorting purpose

      # Priority 2: Distance categories
      distance_category =
        if destination[:flight_track].average_flight_time_min < 120
          0
        elsif destination[:flight_track].average_flight_time_min < 180
          1
        else
          2
        end

      # Priority 3: Heading groups
      heading_category =
        case destination[:flight_track].bearing
        when 0..90
          0
        when 91..180
          1
        when 181..270
          2
        else
          3
        end

      # Priority 4: Matching fuel card provider
      if destination[:airport].fuel_station.nil?
        fuel_card_category = 1
      else
        fuel_cards = []
        fuel_cards << 'Air BP' if @trip_request.user.pilot_pref.fuel_card_bp
        if @trip_request.user.pilot_pref.fuel_card_total
          fuel_cards << 'Total Energies'
        end
        if fuel_cards.include?(destination[:airport].fuel_station.provider)
          fuel_card_category = 0
        else
          fuel_card_category = 1
        end
      end

      airports_priority_groups << { airport_id: destination[:airport].id,
                                    direct_flight:,
                                    distance_group: distance_category,
                                    heading_group: heading_category,
                                    fuel_card_group: fuel_card_category }
    end

    # Sorting rules
    sorted_destinations = airports_priority_groups.sort_by do |hash|
      [hash[:direct_flight], hash[:distance_group], hash[:heading_group],
       hash[:fuel_card_group]]
    end

    # Unique destinations - avoid having airports in same 3 groups
    sorted_destinations = sorted_destinations.sort_by do |hash|
      [hash[:direct_flight], hash[:distance_group], hash[:heading_group]]
    end
    unique_destinations = sorted_destinations.uniq do |hash|
      [hash[:direct_flight], hash[:distance_group], hash[:heading_group]]
    end

    # Create array of airports
    unique_destinations.each do |destination|
      top_destination_airports << Airport.find(destination[:airport_id])
    end

    # Send the airports in array
    @top_destination_airports = top_destination_airports.first(10)
  end
end
