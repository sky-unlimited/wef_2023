class Destinations

  attr_reader :airports_matching_criterias, :flyzone_outbound, :flyzone_inbound, :flyzone_common_polygon

  def initialize(trip_request)
    @trip_request = trip_request
    @flyzone_outbound = nil
    @flyzone_inbound = nil
    @flyzone_common_polygon = nil
    @airports_matching_criterias = []
    @airports_flyzone_common = []
    @airports_top_destinations = []

    create_flyzones
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
