# WeatherTiles represents the group of multiple Tiles to build a flyable zone.

class WeatherTiles

  attr_reader :tiles

  # WeatherTiles initialization
  def initialize(current_user, airport, start_date, end_date = nil)
    @weather_profile = PilotPref.find_by(user_id: current_user).weather_profile
    @precision =  WANDERBIRD_CONFIG['default_weather_tile_precision'].to_f
    @depth =      WANDERBIRD_CONFIG['default_weather_tile_depth'].to_i
    @start_date = start_date
    @end_date   = end_date
    @airport_departure = airport
    @start_date_weather_ok  = false
    @end_date_weather_ok    = false
    @tiles = []

    # We check that the precision given in the config file is in the expected values.
    raise Exception.new("WeatherTile precision #{@precision} is not permitted! Accepted values: 0.25, 0.5 and 1") unless [0.25, 0.5, 1].include?(@precision)

    # We create the first tile at instantation
    origin_tile = WeatherTile.new(@weather_profile, @start_date, @precision, nil, nil, @airport_departure)
    @tiles.push(origin_tile)

    # We set the weather condition for the first tile. It has to be ok to continue
    @start_date_weather_ok = origin_tile.weather_ok

    # We create the first tile at instantation
    second_tile = WeatherTile.new(@weather_profile, 
                                  @start_date,
                                  @precision,
                                  origin_tile.lon_tile_origin + @precision,
                                  origin_tile.lat_tile_origin,
                                  nil)
  end

  private


end
