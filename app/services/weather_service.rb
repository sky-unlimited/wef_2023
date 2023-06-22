require 'rest-client'

class WeatherService
  def self.getWeather(lat, lon)
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
end
