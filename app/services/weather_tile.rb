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
# "O" Origin point of a weather tile
#   => (lon_tile_origin, lat_tile_origin)
# "C" Center point of a tile on which we'll the weather information
#   => (lon_center, lat_center)
# "A" if provided, represents the Airport lto determine the first tile (airport)
# Example:
#   ELLX Luxembourg
#   Precision: 1
#   A (6.204444,49.6233333)
#   C (6.5, 49.5)
#   O (6,49)
class WeatherTile
  attr_reader :polygon_geometry, :lon_center, :lat_center, :lon_tile_origin,
              :lat_tile_origin, :is_weather_pilot_compliant,
              :weather_data_to_date

  # TODO; Delete args user, and replace effective_date by offset
  def initialize(pilot_pref, effective_date, lon_tile_origin = nil,
                 lat_tile_origin = nil, airport = nil)
    # User and it's weather preferences
    @pilot_pref = pilot_pref
    # Date to retrieve weather information
    @effective_date = effective_date
    # Precision is the size of a tile. Smaller = more precise weather
    @precision  = WEF_CONFIG['default_weather_tile_precision'].to_f
    # Longitude center of the tile "C"
    @lon_center = nil
    # Latitude  center of the tile "C"
    @lat_center = nil
    # Longitude of the origin point of the tile "O"
    @lon_tile_origin = lon_tile_origin
    # Latitude  of the origin point of the tile "O"
    @lat_tile_origin = lat_tile_origin
    # Will store the daily weather for original tile
    @weather_data = nil
    # Polygon of the tile in RGeo factory format
    @polygon_geometry = nil
    # We check if weather if pilot compliant
    @is_weather_pilot_compliant = false
    # Airport if origin tile (first tile)
    @airport = airport

    # If the tile is instantiated with an airport, it means we have first to
    # compute the bottom left coordinate.
    # All other tiles are determined based on this initial point.
    unless airport.nil?
      @lon_tile_origin = WeatherTile.get_origin(airport.longitude,
                                                airport.latitude)[:longitude]
      @lat_tile_origin = WeatherTile.get_origin(airport.longitude,
                                                airport.latitude)[:latitude]
    end
    # We now have all info to create the tile while instantiation
    create_tile
    @is_weather_pilot_compliant =
      @pilot_pref.weather_pilot_compliant?(daily_weather)
  end

  # This method takes a latitude as input, places in a tile depending the
  # precision, and sends back the middle latitude of the tile.
  def self.coordinate_to_tile_center(latitude, longitude)
    precision = WEF_CONFIG['default_weather_tile_precision']
    origin_tile_coordinates = get_origin(longitude, latitude)
    {
      latitude: origin_tile_coordinates[:latitude] + (precision.to_f / 2),
      longitude: origin_tile_coordinates[:longitude] + (precision.to_f / 2)
    }
  end

  def self.get_origin(longitude, latitude)
    # origin contains the bottom left coordinate of the airport origin tile
    origin = []

    # Departure airport coordinates
    coordinates = [longitude, latitude]

    # For each lon / lat we determine the tile minimums depending the precision
    # left_boundary is the minimum of a coordinate. Example:
    #   longitude: 6.2 => left_boundary = 6.0
    coordinates.each do |coordinate|
      left_boundary = coordinate.floor

      case @precision
      when 0.25
        if coordinate < left_boundary + (1 * @precision)
          left_boundary = left_boundary
        elsif coordinate < left_boundary + (2 * @precision)
          left_boundary += (1 * @precision)
        elsif coordinate < left_boundary + (3 * @precision)
          left_boundary += (2 * @precision)
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

    # origin.first is the boundary of longitude
    # origin.last  is the boundary of latitude
    # We return a hash
    { longitude: origin.first, latitude: origin.last }
  end

  def self.coordinates_to_tile_center(lat, lon)
    precision = WEF_CONFIG['default_weather_tile_precision'].to_f
    lat_center = lat.floor +
                 ((1 +  (((lat - lat.floor) / precision).floor * 2)) *
                  (precision / 2))
    lon_center = lon.floor +
                 ((1 +  (((lon - lon.floor) / precision).floor * 2)) *
                  (precision / 2))

    { latitude: lat_center, longitude: lon_center }
  end

  private

  def create_tile
    # We define the coordinates of the tile depending on the departure airport
    #   and precision
    # Exemple:  ELLX Airport
    #           longitude: 6.20444 latitude: 49.6233333
    #           Precision: 1
    #           See results below in comments
    #           !!! To obtain a square tile, top_tile * (4/6)
    left_tile    = @lon_tile_origin
    right_tile   = @lon_tile_origin + @precision
    bottom_tile  = @lat_tile_origin
    top_tile     = @lat_tile_origin + (@precision * (1.to_f / 1))

    # x axis is longitude
    # y axis is latitude
    # polygon is couple of x,y
    polygon = [
      [left_tile,  bottom_tile],
      [right_tile, bottom_tile],
      [right_tile, top_tile],
      [left_tile,  top_tile],
      [left_tile,  bottom_tile]
    ]

    # We deduct the polygon geometry representation by using a Factory
    # factory = RGeo::Geographic.spherical_factory(srid: 4326)
    factory = RGeo::Geos.factory(srid: 4326)

    # Create an array of RGeo::Feature::Point objects
    points = polygon.map { |coord| factory.point(coord[0], coord[1]) }

    # Create a linear ring from the array of points
    ring = factory.linear_ring(points)

    # Create a polygon object from the linear ring
    @polygon_geometry = factory.polygon(ring)

    # We define the center of the tile to call weather state
    @lon_center = left_tile   + ((right_tile.to_f - left_tile.to_f) / 2)
    @lat_center = bottom_tile + ((top_tile.to_f - bottom_tile.to_f) / 2)
  end

  def daily_weather
    # We need to determine at which date we need the weather
    # Openweather API provides daily forecast for 7 days
    day_offset = (@effective_date.to_date - Date.current).to_i

    # We retrieve the weather for a defined forecast day
    weather_daily = Weather.read(@lat_center, @lon_center)['daily'][day_offset]

    # If origin tile, we load weather
    @weather_data_to_date = weather_daily unless @airport.nil?
    weather_daily
  end
end
