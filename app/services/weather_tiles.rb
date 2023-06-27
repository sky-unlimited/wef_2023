# WeatherTiles represents the group of multiple Tiles to build a flyable zone.

class WeatherTiles

  attr_reader :tiles, :start_date_weather_ok, :start_date_weather_data

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
    @start_date_weather_data  = nil #Could be used in the view bad_weather.html to customize page depending weather
    @end_date_weather_data    = nil #Could be used in the view bad_weather.html to customize page depending weather
    @tiles = []
    @x = nil                        # grid iteration longitude
    @y = nil                        # grid iteration latitude
    @origin_x = nil                 # The origin longitude of the first tile
    @origin_y = nil                 # The origin latitude  of the first tile

    # We check that the precision given in the config file is in the expected values.
    raise Exception.new("WeatherTile precision #{@precision} is not permitted! Accepted values: 0.25, 0.5 and 1") unless [0.25, 0.5, 1].include?(@precision)

    # We create the origin tile
    origin_tile = WeatherTile.new(@weather_profile, @start_date, @precision, nil, nil, @airport_departure)
    @tiles.push(origin_tile)
    @origin_x = origin_tile.lon_tile_origin # will define the center of the weather grid -> lon
    @origin_y = origin_tile.lat_tile_origin # will define the center of the weather grid -> lon

    # We check that the weather is ok on the initial tile
    @start_date_weather_data = origin_tile.weather_data           # used by controller to display information on the view
    @start_date_weather_ok = true if origin_tile.weather_ok

    # We launch the progagation algo for a defined date
    propagation_algo() unless start_date_weather_ok = false

  end

  private

  def propagation_algo()
    # Center initial coordinates init
    @x = @origin_x
    @y = @origin_y

    # Grid initialization - The grid is a virtual representation of the weather tiles centered on the tile 
    # containing the departure airport
    indexes = (@precision * 2) + 1
    @tiles_grid    = Array.new(indexes) { Array.new(indexes, 0) }
    @tiles_visited = Array.new(indexes) { Array.new(indexes, 0) }

    # If bad weather on initial tile, we stop the process
    return if @start_date_weather_ok == true
    
    # We continue the process and explore the surroundings of the initial tile
    stop_loop = 0
    (1..@precision).each do | depth |
      stop_loop = explore_depth_level(@x , @y, @tiles_grid,  depth, @tiles_visited)
      break if stop_loop == 1
    end

  end

  def explore_depth_level(x_init, y_initt, grid, depth_level, visited)
    bad_weather_count = 0
    ((x_init - depth_level)..(x_init + depth_level)).each do |x|
      ((y_init - depth_level)..(y_init + depth_level)).each do |y|
        # code
      end
    end
  end
end
