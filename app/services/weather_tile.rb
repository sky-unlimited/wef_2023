require 'json'

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
  attr_reader :points, :lon_center, :lat_center, :lon_tile_origin, :lat_tile_origin, :weather_data, :date

  def initialize(date, precision, lon_tile_origin=nil, lat_tile_origin=nil, airport=nil)
    @points = nil           # represents coordiates of tile's corners
    @lon_center = nil
    @lat_center = nil
    @weather_data = nil
    @lon_tile_origin = lon_tile_origin 
    @lat_tile_origin = lat_tile_origin
    @date = date            # At which date should we retrieve weather information
    @precision = precision  # Precision is the size of a tile. The smaller, the more precise is the weather
    @airport_departure = airport

    # If the tile is instantiated with an airport, it means we have first to 
    # compute determine the bottom left coordinate.
    # All other tiles are determined based on this initial point.
    get_initial_boundaries unless @airport_departure.nil?

    # We now have all info to create the tile while instantiation
    createTile
  end

  private

  def get_initial_boundaries
    # boundaries contains the bottom left coordinate of the airport origin tile
    boundaries = []

    # Departure airport coordinates
    coordinates = [ @airport_departure.longitude, @airport_departure.latitude ]
    
    # For each lon / lat we determine the tile minimums depending the precision
    coordinates.each do |coordinate| 
      left_boundary   = coordinate.floor

      case precision
      when 0.25
        if number < left_boundary + ( 1 * precision )
          left_boundary = left_boundary
        elsif number < left_boundary + ( 2 * precision )
          left_boundary += ( 1 * precision )
        elsif number < left_boundary + ( 3 * precision )
          left_boundary  += ( 2 * precision )
        else
          left_boundary += 3 * precision
        end
      when 0.5
        left_boundary += precision if number >= left_boundary + precision
      else
        left_boundary = left_boundary
      end
      boundaries.push(left_boundary)
    end

    @lon_tile_origin = boundaries[0]
    @lat_tile_origin = boundaries[1]
  end

  def create_tile
    # We define the coordinates of the tile depending on the airport and precision
    # Exemple:  ELLX Airport
    #           longitude: 6.20444 latitude: 49.6233333
    #           Precision: 1
    #           See results below in comments
    left_tile    = @lon_lat_origin                  #6  ELLX
    right_tile   = @lon_lat_origin  + @precision    #7  ELLX
    bottom_tile  = @lat_tile_origin                 #49 ELLX
    top_tile     = @lat_tile_origin + @precision    #50 ELLX

    # x axis is longitude
    # y axis is latitude
    # points is couple of x,y
    @points = [
      [ left_tile,  bottom_tile ],
      [ right_tile, bottom_tile ],
      [ right_tile, top_tile ],
      [ left_tile,  top_tile ],
      [ left_tile,  bottom_tile ],
    ]
    
    # We define the center of the tile to call weather state
    @center_lon = left_tile   + ( right_tile.to_f - left_tile.to_f ) / 2
    @center_lat = bottom_tile + ( top_tile.to_f - bottom_tile.to_f ) / 2

    # We need to determine at which date we need the weather
    day_difference = (Date.current - @date.to_date).to_i

    # We retrieve the WeatherCall id
    weather_record_id = WeatherService::getWeather(@center_lat, @center_lon)

    # We read and assign the corresponding weather info
    #   Exemple: {"id"=>502, "main"=>"Rain", "description"=>"heavy intensity rain", "icon"=>"10d"}
    @weather_data =  JSON.parse(WeatherCall.find(weather_record_id).json)["daily"][day_difference]["weather"][0]

    # Depending on the pilot profile, we decide if the tile is ok or nok
  end

end
