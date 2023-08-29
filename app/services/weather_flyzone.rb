# WeatherFlyzone represents a collection of WeatherTile created in 
# one polygon (GIS).
# It represents the geographic area where a defined pilot can fly from
# a defined airport, at a defined date.
class WeatherFlyzone

  attr_reader :tiles, :weather_ok_to_date, :weather_data_to_date, :flyzone_polygon

  # WeatherFlyzone initialization
  def initialize(trip_request, effective_date)
    @trip_request = trip_request
    @effective_date = effective_date
    @pilot_weather_profile  =  PilotPref.find_by(user_id: trip_request.user_id).weather_profile
    @pilot_max_wind         =  PilotPref.find_by(user_id: trip_request.user_id).max_gnd_wind_speed.to_i
    @precision  = WEF_CONFIG['default_weather_tile_precision'].to_f
    @depth      = WEF_CONFIG['default_weather_tile_depth'].to_i
    @airport_departure = trip_request.airport
    @weather_ok_to_date  = false    # Represents if the weather of the original tile is ok
    @weather_data_to_date  = nil    # Represents the weather detail of the original tile
    @tiles = []
    @tile_offset_x = []             # Represents the longitude offset between Tile and virtual grid
    @tile_offset_y = []             # Represents the latitude offset between Tile and virtual grid
    @flyzone_polygon = nil          # The polygon that should union the adjacent good weather tiles

    # We check that the precision given in the config file is in the expected values.
    raise Exception.new("WeatherTile precision #{@precision} is not permitted! Accepted values: 0.25, 0.5 and 1") unless [0.25, 0.5, 1].include?(@precision)

    # We create the origin tile
    origin_tile = WeatherTile.new(@trip_request.user, @effective_date, @precision, nil, nil, @airport_departure)
    @tiles.push(origin_tile)
    x_tile_init = origin_tile.lon_tile_origin # will define the center of the weather grid -> lon
    y_tile_init = origin_tile.lat_tile_origin # will define the center of the weather grid -> lon
    
    # We check that the weather is ok on the initial tile
    @weather_data_to_date = origin_tile.weather_data           # used by controller to display information on the view
    @weather_ok_to_date   = true if origin_tile.weather_ok

    # We launch the progagation algo for a defined date only in case of good weather at departure airport
    # If bad weather, no polygon created
    propagation_algo(x_tile_init, y_tile_init) unless @weather_ok_to_date == false

  end

  private

  def propagation_algo(x_tile_init, y_tile_init)
    # In order to keep a ratio y/x close to 1, we compute a correction factor
    correction_x = @depth.odd? ? @depth + 1 : @depth
    
    # Grid parameters initialization
    indexes_x = ((@depth * 2) + 1) + correction_x
    indexes_y = (@depth * 2) + 1
    x_grid_init = (indexes_x / 2).to_i  # center x
    y_grid_init = (indexes_y / 2).to_i  # center y
    
    # Virtual grid is a represenation of the geometric tiles
    virtual_grid         = Array.new(indexes_y) { Array.new(indexes_x, 0) } 
    # used for the algo
    virtual_grid_visited = Array.new(indexes_y) { Array.new(indexes_x, 0) }
    
    # Tile Longitude offsets depending the precisions
    @tile_offset_x = []
    (0..(virtual_grid[0].count - 1)).each do |x|
      @tile_offset_x[x] = ( x * @precision) + ( x_tile_init - ( (virtual_grid[0].count / 2).floor ) * @precision )
    end

    # Tile Latitude offsets depending of the precisions
    @tile_offset_y = []
    (0..(virtual_grid.count - 1)).each do |y|
      @tile_offset_y[y] = ( y * @precision) + ( y_tile_init - ( (virtual_grid.count / 2).floor ) * @precision )
    end

    # At this stage, weather on initial tile is ok
    virtual_grid[y_grid_init][x_grid_init] = 2

    # We continue the process and explore the surroundings of the initial tile, depth by depth
    stop_loop = 0
    (1..@depth + correction_x).each do | current_depth |
      stop_loop = explore_depth_level(x_grid_init,
                                      y_grid_init,
                                      virtual_grid,
                                      current_depth,
                                      virtual_grid_visited,
                                      x_tile_init,
                                      y_tile_init,
                                      @depth
                                     )
      break if stop_loop == 1
    end
    
    # We execute the union test, in other words, the fly zone of inteconnected good weather tiles. No isolated.
    union_test(x_grid_init, y_grid_init, virtual_grid, virtual_grid_visited)

  end

  # The explore_depth_level works on 2 grids:
    # The virtual grid which is an array the represents the tiles
    # The geometric tiles themselfs, which contain their real origin points, bottom left
  # Here's a representation on one axis:
  # ==========================================
  # | Virtual Grid (x)  ||  Tile longitude   |
  # ==========================================
  # | 0 | 1 | 2 | 3 | 4 || 4 | 5 | 6 | 7 | 8 |
  # ------------------------------------------
  # | 0 | 1 | 2 | 3 | 4 || 4 | 5 | 6 | 7 | 8 |
  # ------------------------------------------
  # | 0 | 1 | 2 | 3 | 4 || 4 | 5 | 6 | 7 | 8 |
  # ------------------------------------------
  # | 0 | 1 | 2 | 3 | 4 || 4 | 5 | 6 | 7 | 8 |
  # ------------------------------------------
  # | 0 | 1 | 2 | 3 | 4 || 4 | 5 | 6 | 7 | 8 |
  # ==========================================
  # For ELLX for example:
    # the center of the tiles grid is lon=6, lat=49
    # the center of the virtual grid is x=2, y=2
  # THE ARRAY GRID IS THE VIRTUAL REPRESENTATION OF THE TILES 
  def explore_depth_level(x_grid_init, y_grid_init, grid, current_depth, visited, x_tile_init, y_tile_init, max_y)
    # Variable init
    bad_weather_count = 0

    # We visit all the tiles depending the current depth_level
    ((x_grid_init - current_depth)..(x_grid_init + current_depth)).each do |x|
      ((y_grid_init - [current_depth, max_y].min)..(y_grid_init + [current_depth, max_y].min)).each do |y|
        # We create the tile
        if grid[y][x] == 0  # cell is not visited
          tile = WeatherTile.new( @trip_request.user,
                                  @effective_date, 
                                  @precision, 
                                  @tile_offset_x[x], 
                                  @tile_offset_y[y], 
                                  nil)
          @tiles.push(tile) unless (x == x_grid_init && y == y_grid_init) # origin tile already pushed

          if tile.weather_ok
           grid[y][x] = 2   # cell is good weather
          else 
            grid[y][x] = 1  # cell was visited
            bad_weather_count += 1
          end
        end
      end
    end
    return if bad_weather_count == current_depth * 8 ? 1 : 0
  end

  def union_test(x, y, grid, visited)
    if ( grid[y][x] == 2 || grid[y][x] == 3 ) && visited[y][x] == 0
      visited[y][x] = 1
      grid[y][x] = 3        # cell should be part of flyzone

      # We search the corresponding weather tile
      corresponding_tile = @tiles.find { |tile| tile.lon_tile_origin == @tile_offset_x[x] &&
                                             tile.lat_tile_origin == @tile_offset_y[y] }
      
      corresponding_tile.is_in_fly_zone = true if corresponding_tile

      if @flyzone_polygon.nil?
        @flyzone_polygon = corresponding_tile.polygon_geometry
      else
        @flyzone_polygon = @flyzone_polygon.union(corresponding_tile.polygon_geometry)
      end

      # We call recursively all adjacent cells
      union_test(x + 1, y, grid, visited) if x + 1 < grid[0].length
      union_test(x - 1, y, grid, visited) if x > 0
      union_test(x, y + 1, grid, visited) if y + 1 < grid.length
      union_test(x, y - 1, grid, visited) if y > 0
    end
    
  end
end
