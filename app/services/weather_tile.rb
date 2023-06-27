require 'json'
require 'rgeo'

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

  def initialize(pilot_profile, date, precision, lon_tile_origin=nil, lat_tile_origin=nil, airport=nil)
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
    @pilot_profile = pilot_profile      # The pilot weather profile (safe, ...)
    @weather_ok = false                 # Summarizes if tile's weather is in pilot's acceptance criteria (PilotPref.weather_profile)

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
        if number < left_boundary + ( 1 * @precision )
          left_boundary = left_boundary
        elsif number < left_boundary + ( 2 * @precision )
          left_boundary += ( 1 * @precision )
        elsif number < left_boundary + ( 3 * @precision )
          left_boundary  += ( 2 * @precision )
        else
          left_boundary += 3 * @precision
        end
      when 0.5
        left_boundary += @precision if number >= left_boundary + @precision
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
    left_tile    = @lon_tile_origin                 #6  ELLX
    right_tile   = @lon_tile_origin + @precision    #7  ELLX
    bottom_tile  = @lat_tile_origin                 #49 ELLX
    top_tile     = @lat_tile_origin + @precision    #50 ELLX

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
    factory = RGeo::Geographic.spherical_factory(srid: 4326)

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
    # Openweather API provides daily forecast for 8 days
    # FIXME: issue#29
    day_difference = [ 7, (@date.to_date - Date.current ).to_i ].min

    # We retrieve the WeatherCall id
    # comment below in case of fake weather call
    #weather_record_id = WeatherService::get_weather(@lat_center, @lon_center)

    # We read and assign the corresponding weather info
    #   Exemple: {"id"=>502, "main"=>"Rain", "description"=>"heavy intensity rain", "icon"=>"10d"}
    #@weather_data =  JSON.parse(WeatherCall.find(weather_record_id).json)["daily"][day_difference]["weather"][0]
    # To activate fake weather, comment above, uncomment below
    @weather_data = WeatherService::get_fake_weather(@lat_center, @lon_center)

    # Depending on the pilot weather profile, we decide if the tile asociated weather is ok or nok
    weather_profiles =  WANDERBIRD_CONFIG['weather_profiles']

    # The pilot weather profile is "safe"
    if @pilot_profile = PilotPref.weather_profiles.keys[0]
      if weather_profiles[0]["safe"].include?(@weather_data["id"])
        @weather_ok = true
      end
    end

    # The pilot weather profile is "adventurous"
    if @pilot_profile = PilotPref.weather_profiles.keys[1]
      if weather_profiles[0]["safe"].include?(@weather_data["id"]) or
         weather_profiles[1]["adventurous"].include?(@weather_data["id"])
        @weather_ok = true
      end
    end

  end

end
