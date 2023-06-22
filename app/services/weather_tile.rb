require 'json'

class WeatherTile
  attr_reader :points, :center_lon, :center_lat, :weather_data, :start_date, :return_date
  def initialize(airport, start_date, return_date=nil)
    @precision =  WANDERBIRD_CONFIG['default_weather_tile_precision'].to_f
    @depth =      WANDERBIRD_CONFIG['default_weather_tile_depth'].to_i
    @start_date   = start_date
    @return_date  = return_date
    @points = nil
    @center_lon = nil
    @center_lat = nil
    @weather_data = nil

    # We check that the precision given in the config file is in the expected values.
    check_precision

    # We create at the tile at instantation
    create_tile(airport)

  end

  private

  def check_precision
    raise Exception.new("WeatherTile precision #{@precision} is not permitted! Accepted values: 0.25, 0.5 and 1") unless [0.25, 0.5, 1].include?(@precision)
  end

  def create_tile(airport)
    # We define the coordinates of the tile depending on the airport and precision
    # Exemple:  ELLX Airport
    #           longitude: 6.20444 latitude: 49.6233333
    #           Precision: 1
    #           See results below in comments
    left_tile    = computeBoundaries(airport.longitude)[0]  #6  ELLX
    right_tile   = computeBoundaries(airport.longitude)[1]  #7  ELLX
    bottom_tile  = computeBoundaries(airport.latitude)[0]   #49 ELLX
    top_tile     = computeBoundaries(airport.latitude)[1]   #50 ELLX

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
    day_difference = (Date.current - @start_date.to_date).to_i

    # We retrieve the WeatherCall id
    weather_record_id = WeatherService::getWeather(@center_lat, @center_lon)

    # We read and assign the corresponding weather info
    #   Exemple: {"id"=>502, "main"=>"Rain", "description"=>"heavy intensity rain", "icon"=>"10d"}
    @weather_data =  JSON.parse(WeatherCall.find(weather_record_id).json)["daily"][day_difference]["weather"][0]

    # Depending on the pilot profile, we decide if the tile is ok or nok
  end

  def computeBoundaries(number)
    left_boundary   = number.floor

    case @precision
    when 1
      left_boundary = left_boundary
    when 0.5
      left_boundary += @precision if number >= left_boundary + @precision
    when 0.25
      if number < left_boundary + ( 1 * @precision )
        left_boundary = left_boundary
      elsif number < left_boundary + ( 2 * @precision )
        left_boundary += ( 1 * precision )
      elsif number < left_boundary + ( 3 * @precision )
        left_boundary  += ( 2 * @precision )
      else
        left_boundary += 3 * @precision
      end
    end

    return [ left_boundary, left_boundary + @precision ]
  end
end
