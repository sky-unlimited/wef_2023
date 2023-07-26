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
  attr_reader :polygon, :polygon_geometry, :lon_center, :lat_center, :lon_tile_origin, :lat_tile_origin,
              :weather_data, :date, :weather_ok
  attr_accessor :is_in_fly_zone

  def initialize(pilot_weather_profile, pilot_max_wind, date, precision, lon_tile_origin=nil, lat_tile_origin=nil, airport=nil)
    @polygon = nil                      # represents the polygon of the tile
    @polygon_geometry = nil             # represents the polygon of the tile in RGeo factory format
    @lon_center = nil                   # Longitude center of the tile "C"
    @lat_center = nil                   # Latitude  center of the tile "C"
    @weather_data = nil                 # Will store the needed weather info from openweather.com
    @lon_tile_origin = lon_tile_origin  # Longitude of the origin point of the tile "O" 
    @lat_tile_origin = lat_tile_origin  # Latitude  of the origin point of the tile "O"
    @date = date                        # At which date should we retrieve weather information
    @precision = precision              # Precision is the size of a tile. The smaller, the more precise is the weather
    @airport_departure = airport        # Just used for the initial tile
    @weather_ok = false                 # Summarizes if tile's weather is in pilot's acceptance criteria (PilotPref.weather_profile)
    @pilot_weather_profile = pilot_weather_profile  # The pilot weather profile (safe, ...)
    @pilot_max_wind = pilot_max_wind    # pilot's max accepted ground wind
    @is_in_fly_zone = false             # Good weather is not enough. We need to display only the fly zone

    # If the tile is instantiated with an airport, it means we have first to 
    # compute determine the bottom left coordinate.
    # All other tiles are determined based on this initial point.
    get_origin unless @airport_departure.nil?

    # We now have all info to create the tile while instantiation
    create_tile
  end

  private

  def get_origin
    # origin contains the bottom left coordinate of the airport origin tile
    origin = []

    # Departure airport coordinates
    coordinates = [ @airport_departure.longitude, @airport_departure.latitude ]
    
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

    # We create a simple polygon array to be used with Leaflet
    @polygon = [
      [ bottom_tile, left_tile ],
      [ bottom_tile, right_tile ],
      [ top_tile, right_tile ],
      [ top_tile, left_tile ]
    ]
    
    # We define the center of the tile to call weather state
    @lon_center = left_tile   + ( right_tile.to_f - left_tile.to_f ) / 2
    @lat_center = bottom_tile + ( top_tile.to_f - bottom_tile.to_f ) / 2

    # We need to determine at which date we need the weather
    # Openweather API provides daily forecast for 7 days
    day_offset = (@date.to_date - Date.current ).to_i

    # We read and assign the corresponding weather info
    #   Exemple: {"id"=>502, "main"=>"Rain", "description"=>"heavy intensity rain", "icon"=>"10d"}
    if WEF_CONFIG['fake_weather'] == true
      @weather_data = WeatherService::get_fake_weather
    else
      # We retrieve the WeatherCall id
      weather_record_id = WeatherService::get_weather(@lat_center, @lon_center)
      # We read database
      #@weather_data   =  JSON.parse(WeatherCall.find(weather_record_id).json)["daily"][day_offset]["weather"][0]
      @weather_data   =  JSON.parse(WeatherCall.find(weather_record_id).json)["daily"][day_offset]
    end

    # Depending on the pilot weather profile, we deduct if the tile asociated weather is ok or nok
    # We check if weather code belongs to pilot's preference
    @weather_ok = WeatherService::weather_code_in_pilot_profile(@pilot_weather_profile, @weather_data["weather"][0]["id"])

    # We check if wind speed is above pilot's preferences
    if @weather_ok # We weather was already not ok, no need to check the winds
      wind_kts = @weather_data["wind_speed"] * 1.9438445
      @weather_ok = wind_kts.round(0) <= @pilot_max_wind ? true : false
    end
  end

end
