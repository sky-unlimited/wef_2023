require 'json'
require 'rgeo'

class FlightTrack
  attr_reader :start_point, :end_point, :distance_km, :distance_nm, :average_flight_time_min,
              :line, :bearing

  # parameters:
  #   start_point:  geography(st_point: 4326)
  #   end_point:    geography(st_point: 4326)
  #   average_tas_kts:  integer (represents average true airspeed in knots)
  def initialize(start_point, end_point, average_tas_kts)
    @start_point = start_point
    @end_point = end_point
    @distance_km = (@start_point.distance(@end_point)/1000).to_i
    @distance_nm = (@distance_km / 1.852).to_i
    @average_flight_time_min = ((@distance_nm.to_f / average_tas_kts)*60).to_i

    create_line
    calculate_bearing(start_point, end_point)
  end

  # parameters
  #   flyzone:      geography(st_polygon: 3857)
  def is_in_flyzone(flyzone)
    # p pt.within?(polygon)
  end

  private

  def create_line
    factory = RGeo::Geographic.simple_mercator_factory #srid: 4326
    @line = RGeo::GeoJSON.encode(factory.line_string([start_point, end_point]))
  end

  def calculate_bearing(start_point, end_point)
    factory = RGeo::Geographic.simple_mercator_factory #srid: 4326
    line_string = factory.line_string([start_point, end_point])

    # Extract start and end coordinates
    start_coords = line_string.coordinates[0]
    end_coords = line_string.coordinates[-1]

    lat1 = radians(start_coords[1])
    lon1 = radians(start_coords[0])
    lat2 = radians(end_coords[1])
    lon2 = radians(end_coords[0])

    delta_lon = lon2 - lon1

    y = Math.sin(delta_lon) * Math.cos(lat2)
    x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(delta_lon)

    initial_bearing = Math.atan2(y, x)
    initial_bearing = (initial_bearing + 360) % 360 # Normalize to [0, 360] degrees

    @bearing = initial_bearing.round(0)
  end

  def radians(degrees)
    degrees * Math::PI / 180.0
  end
end
