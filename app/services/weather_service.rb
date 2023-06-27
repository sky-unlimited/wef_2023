require 'rest-client'

class WeatherService
  def self.get_weather(lat, lon)
    # We check if weather available in database and inside validity
    db_weather = WeatherCall.where(lon: lon, lat: lat).last

    # If available, we return it
    unless db_weather.nil?
      # We check if weather call created inside validity tolerance and same location
      if Time.now.hour - db_weather.created_at.hour <= WANDERBIRD_CONFIG['default_weather_calls_validity_hours'].to_i &&
        db_weather.created_at.today? &&
        db_weather.lon.round(6) == lon.round(6) &&
        db_weather.lat.round(6) == lat.round(6)
        return db_weather.id
      end
    end

    # If not, we call the weather api
    api_call = RestClient.get 'https://api.openweathermap.org/data/3.0/onecall', 
      {params: 
       {lat: lat, 
        lon: lon, 
        appid: ENV["OPENWEATHERMAP_API"],
        exclude: "current,hourly,minutely",
        units: "metric"}
      }
    weather_call = JSON.parse( api_call )

    # We store it in database
    WeatherCall.create(lat: weather_call["lat"].round(6),
                       lon: weather_call["lon"].round(6),
                       json: api_call)

    # And we retrive the id of the record in database
    return  WeatherCall.where(  lat: weather_call["lat"].round(6),
                                lon: weather_call["lon"].round(6)
                             ).pluck(:id).last
  end

  def self.get_fake_weather(lat,lon)
    # We load bad weather possibilities
    bad_weather_sample = self.random_bad_weather

    # Random weather
    if rand(0..3) < 1
      # bad weather
      fake_data = {
              "id" => bad_weather_sample["id"],
              "main" => bad_weather_sample["main"],
              "description" => bad_weather_sample["description"],
              "icon" => bad_weather_sample["icon"]
            }
    else
      # good weather
      fake_data = { "id" => 800, "main" => "Clear", "description" => "clear sky", "icon" => "01d" }
    end
  end
  
  private

  def self.random_bad_weather()
    random = rand(0..2)
    case random
    when 0
      { "id" => 212, "main" => "Thunderstorm", "description" => "heavy thunderstorm", "icon" => "11d" }
    when 2
      { "id" => 602, "main" => "Snow", "description" => "very heavy snow", "icon" => "13d" }
    else
      { "id" => 503, "main" => "Rain", "description" => "very heavy rain", "icon" => "10d" }
    end
  end

end
