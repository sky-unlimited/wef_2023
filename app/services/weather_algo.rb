class WeatherAlgo

  # WeatherAlgo initialization
  def initialize(airport, start_date, end_date = nil)
    @precision =  WANDERBIRD_CONFIG['default_weather_tile_precision'].to_f
    @depth =      WANDERBIRD_CONFIG['default_weather_tile_depth'].to_i
    @start_date   = start_date
    @end_date  = end_date
    @airport_departure = airport
    @start_date_weather_ok = false
    @end_date_weather_ok = false

    # We check that the precision given in the config file is in the expected values.
    raise Exception.new("WeatherTile precision #{@precision} is not permitted! Accepted values: 0.25, 0.5 and 1") unless [0.25, 0.5, 1].include?(@precision)

    # We create the first tile at instantation
    origin_tile = WeatherTile.new(@start_date, @precision, nil, nil, @airport_departure)

    
    
  end

  private

end
