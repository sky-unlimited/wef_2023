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
    # Random weather
    if rand(0..3) < 1 # 25% bad weather probability
      # We load bad weather possibilities
      fake_data = self.random_bad_weather
    else
      # good weather
      fake_data = find_weather_description_by_id(800)
    end
  end

  def self.weather_code_in_pilot_profile(pilot_weather_profile, id)
    weather_profiles =  WANDERBIRD_CONFIG['weather_profiles']
    weather_ok = false

    # The pilot weather profile is "safe"
    if pilot_weather_profile == PilotPref.weather_profiles.keys[0]
      if weather_profiles[0]["safe"].include?(id)
        weather_ok = true
      end
    end

    # The pilot weather profile is "adventurous"
    if pilot_weather_profile == PilotPref.weather_profiles.keys[1]
      if weather_profiles[0]["safe"].include?(id) or
         weather_profiles[1]["adventurous"].include?(id)
        weather_ok = true
      end
    end

    return weather_ok
  end

  # Return a hash with weather description
  def self.find_weather_description_by_id(id)
    #OPTIMIZE: List here all codes from https://openweathermap.org/weather-conditions issue#45
    array = [
      { "id" => 210, "main" => "Thunderstorm", "description" => I18n.t('weather.210'), "icon" => "11d" },
      { "id" => 212, "main" => "Thunderstorm", "description" => I18n.t('weather.212'), "icon" => "11d" },
      { "id" => 300, "main" => "Drizzle", "description" => I18n.t('weather.300'), "icon" => "09d" },
      { "id" => 310, "main" => "Drizzle", "description" => I18n.t('weather.310'), "icon" => "09d" },
      { "id" => 500, "main" => "Rain", "description" => I18n.t('weather.500'), "icon" => "10d" },
      { "id" => 501, "main" => "Rain", "description" => I18n.t('weather.501'), "icon" => "10d" },
      { "id" => 503, "main" => "Rain", "description" => I18n.t('weather.503'), "icon" => "10d" },
      { "id" => 520, "main" => "Rain", "description" => I18n.t('weather.520'), "icon" => "09d" },
      { "id" => 600, "main" => "Snow", "description" => I18n.t('weather.600'), "icon" => "13d" },
      { "id" => 602, "main" => "Snow", "description" => I18n.t('weather.602'), "icon" => "13d" },
      { "id" => 800, "main" => "Clear", "description" => I18n.t('weather.800'), "icon" => "01d" },
      { "id" => 801, "main" => "Clouds", "description" => I18n.t('weather.801'), "icon" => "02d" },
      { "id" => 802, "main" => "Clouds", "description" => I18n.t('weather.802'), "icon" => "03d" },
      { "id" => 803, "main" => "Clouds", "description" => I18n.t('weather.803'), "icon" => "04d" },
      { "id" => 804, "main" => "Clouds", "description" => I18n.t('weather.804'), "icon" => "04d" }
    ]
    
    array.each do |hash|
      return hash if hash["id"] == id
    end
  end

  private

  def self.random_bad_weather()
    case rand(0..2)
    when 0
      find_weather_description_by_id(212)
    when 2
      find_weather_description_by_id(602)
    else
      find_weather_description_by_id(503)
    end
  end

end
