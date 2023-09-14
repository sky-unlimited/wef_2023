require 'json'
require 'rgeo'

class FlightTrack
  attr_reader :start_point, :end_point, :distance_km, :distance_nm, :average_flight_time_min,
              :line, :line_geojson, :bearing, :is_in_flyzone, :warnings

  # parameters:
  #   start_point:  geography(st_point: 4326)
  #   end_point:    geography(st_point: 4326)
  #   average_tas_kts:  integer (represents average true airspeed in knots)
  def initialize(start_point, end_point, average_tas_kts, flyzone)
    @start_point = start_point
    @end_point = end_point
    @distance_km = (@start_point.distance(@end_point)/1000).to_i
    @distance_nm = (@distance_km / 1.852).to_i
    @average_flight_time_min = ((@distance_nm.to_f / average_tas_kts)*60).to_i

    @line = create_line
    @line_geojson = RGeo::GeoJSON.encode(@line)
    @bearing = calculate_bearing(start_point, end_point).round(0)
    @is_in_flyzone = is_in_flyzone?(flyzone)
    @warnings = []

    check_warnings
  end

  private

  def create_line
    factory = RGeo::Geographic.simple_mercator_factory #srid: 4326
    factory.line_string([start_point, end_point])
  end

  def calculate_bearing(start_coords, end_coords)
    lat1 = radians(start_coords.latitude)
    lon1 = radians(start_coords.longitude)
    lat2 = radians(end_coords.latitude)
    lon2 = radians(end_coords.longitude)

    delta_lon = lon2 - lon1

    y = Math.sin(delta_lon) * Math.cos(lat2)
    x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(delta_lon)

    initial_bearing = Math.atan2(y, x)
    initial_bearing = (initial_bearing * 180.0 / Math::PI + 360) % 360 # Normalize to [0, 360] degrees

    return initial_bearing
  end

  def radians(degrees)
    degrees * Math::PI / 180.0
  end

  # parameters
  #   flyzone:      geography(st_polygon: 3857)
  def is_in_flyzone?(flyzone)
    # We convert @line from srid 4326 to 3857
    line3857 = RGeo::Feature.cast(@line, factory: RGeo::Geographic.simple_mercator_factory(srid: 3857))
    line3857.within?(flyzone)
  end

  def check_warnings
    unless @is_in_flyzone
      @warnings << I18n.t('trip_suggestions.warnings.direct_flight_outside_flyzone')
    end
  end
end
