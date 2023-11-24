require 'json'
require 'rgeo'
require 'rgeo/geos'

# ┏━━━━━━━━━━━━━┓
# ┃  A          ┃
# ┃             ┃
# ┃             ┃
# ┃      C      ┃
# ┃             ┃
# ┃             ┃
# ┃             ┃
# O━━━━━━━━━━━━━┛
#
# "O" represents the Origin point of a weather tile (lon_tile_origin, lat_tile_origin)
# "C" represents the Center point of a tile on which we'll the weather information (lon_center, lat_center)
# "A" if provided, represents the Airport location to determine the first tile (airport)
# Example:
#   ELLX Luxembourg
#   Precision: 1
#   A (6.204444,49.6233333)
#   C (6.5, 49.5)
#   O (6,49)
class WeatherTile
  attr_reader :polygon_geometry, :lon_center, :lat_center, :lon_tile_origin, :lat_tile_origin,
              :weather_data

  def initialize(user, effective_date, precision, lon_tile_origin=nil, lat_tile_origin=nil, airport=nil)
    @user = user                        # represents the user and it's weather preferences
    @effective_date = effective_date    # At which date should we retrieve weather information
    @precision = precision              # Precision is the size of a tile. The smaller, the more precise is the weather
    @lon_center = nil                   # Longitude center of the tile "C"
    @lat_center = nil                   # Latitude  center of the tile "C"
    @lon_tile_origin = lon_tile_origin  # Longitude of the origin point of the tile "O" 
    @lat_tile_origin = lat_tile_origin  # Latitude  of the origin point of the tile "O"
    @weather_data = nil                 # Will store the needed weather info from openweather.com
    @polygon_geometry = nil             # represents the polygon of the tile in RGeo factory format

    # If the tile is instantiated with an airport, it means we have first to 
    # compute determine the bottom left coordinate.
    # All other tiles are determined based on this initial point.
    get_origin(airport.longitude, airport.latitude) unless airport.nil?

    # We now have all info to create the tile while instantiation
    create_tile
    get_weather_data
  end

  def is_weather_pilot_compliant?
    # Depend on the pilot weather profile, we deduct if the tile asociated weather is ok or nok
    # We check if weather code belongs to pilot's preference
    WeatherService::is_weather_pilot_compliant?(@user, @weather_data)
  end

  private

  def get_origin(longitude, latitude)
    # origin contains the bottom left coordinate of the airport origin tile
    origin = []

    # Departure airport coordinates
    coordinates = [ longitude, latitude ]
    
    # For each lon / lat we determine the tile minimums depending the precision
    # left_boundary is the minimum of a coordinate. Example:
    #   longitude: 6.2 => left_boundary = 6.0
    coordinates.each do |coordinate| 
      left_boundary   = coordinate.floor

      case @precision
      when 0.25
        if coordinate < left_boundary + ( 1 * @precision )
          left_boundary = left_boundary
        elsif coordinate < left_boundary + ( 2 * @precision )
          left_boundary += ( 1 * @precision )
        elsif coordinate < left_boundary + ( 3 * @precision )
          left_boundary  += ( 2 * @precision )
        else
          left_boundary += 3 * @precision
        end
      when 0.5
        left_boundary += @precision if coordinate >= left_boundary + @precision
      else
        left_boundary = left_boundary
      end
      origin.push(left_boundary)
    end

    @lon_tile_origin = origin.first #left  boundary of longitude
    @lat_tile_origin = origin.last  #left  boundary of latitude
  end

  def create_tile
    # We define the coordinates of the tile depending on the departure airport and precision
    # Exemple:  ELLX Airport
    #           longitude: 6.20444 latitude: 49.6233333
    #           Precision: 1
    #           See results below in comments
    #           !!! To obtain a square tile, top_tile * (4/6)
    left_tile    = @lon_tile_origin                                 #6  ELLX -> if precision=1
    right_tile   = @lon_tile_origin + @precision                    #7  ELLX -> if precision=1
    bottom_tile  = @lat_tile_origin                                 #49 ELLX -> if precision=1
    top_tile     = @lat_tile_origin + (@precision * ( 1.to_f / 1) ) #50 ELLX -> if precision=1

    # x axis is longitude
    # y axis is latitude
    # polygon is couple of x,y
    polygon = [
      [ left_tile,  bottom_tile ],
      [ right_tile, bottom_tile ],
      [ right_tile, top_tile ],
      [ left_tile,  top_tile ],
      [ left_tile,  bottom_tile ]
    ]

    # We deduct the polygon geometry representation by using a Factory
    #factory = RGeo::Geographic.spherical_factory(srid: 4326)
    factory = RGeo::Geos.factory(srid: 4326)

    # Create an array of RGeo::Feature::Point objects
    points = polygon.map { |coord| factory.point(coord[0], coord[1]) }

    # Create a linear ring from the array of points
    ring = factory.linear_ring(points)

    # Create a polygon object from the linear ring
    @polygon_geometry = factory.polygon(ring)

    # We define the center of the tile to call weather state
    @lon_center = left_tile   + ( right_tile.to_f - left_tile.to_f ) / 2
    @lat_center = bottom_tile + ( top_tile.to_f - bottom_tile.to_f ) / 2
  end

  def get_weather_data
    # We need to determine at which date we need the weather
    # Openweather API provides daily forecast for 7 days
    day_offset = (@effective_date.to_date - Date.current ).to_i

    # We retrieve the WeatherCall id
    weather_record_id = WeatherService::get_weather(@lat_center, @lon_center)

    # We get the weather details
    @weather_data =  JSON.parse(WeatherCall.find(weather_record_id).json)["daily"][day_offset]
  end
end
