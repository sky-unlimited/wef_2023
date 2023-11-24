require 'rest-client'

class WeatherService

  @@weather_conditions = [
    { "id" => 200, "main" => "Thunderstorm",  "description" => I18n.t('weather.200'), "icon" => "11d" },
	  { "id" => 201, "main" => "Thunderstorm",  "description" => I18n.t('weather.201'), "icon" => "11d" },
	  { "id" => 202, "main" => "Thunderstorm",  "description" => I18n.t('weather.202'), "icon" => "11d" },
    { "id" => 210, "main" => "Thunderstorm",  "description" => I18n.t('weather.210'), "icon" => "11d" },
	  { "id" => 211, "main" => "Thunderstorm",  "description" => I18n.t('weather.211'), "icon" => "11d" },
    { "id" => 212, "main" => "Thunderstorm",  "description" => I18n.t('weather.212'), "icon" => "11d" },
	  { "id" => 221, "main" => "Thunderstorm",  "description" => I18n.t('weather.221'), "icon" => "11d" },
	  { "id" => 230, "main" => "Thunderstorm",  "description" => I18n.t('weather.230'), "icon" => "11d" },
	  { "id" => 231, "main" => "Thunderstorm",  "description" => I18n.t('weather.231'), "icon" => "11d" },
	  { "id" => 232, "main" => "Thunderstorm",  "description" => I18n.t('weather.232'), "icon" => "11d" },
    { "id" => 300, "main" => "Drizzle",       "description" => I18n.t('weather.300'), "icon" => "09d" },
	  { "id" => 301, "main" => "Drizzle",       "description" => I18n.t('weather.301'), "icon" => "09d" },
	  { "id" => 302, "main" => "Drizzle",       "description" => I18n.t('weather.302'), "icon" => "09d" },
    { "id" => 310, "main" => "Drizzle",       "description" => I18n.t('weather.310'), "icon" => "09d" },
	  { "id" => 311, "main" => "Drizzle",       "description" => I18n.t('weather.311'), "icon" => "09d" },
	  { "id" => 312, "main" => "Drizzle",       "description" => I18n.t('weather.312'), "icon" => "09d" },
	  { "id" => 313, "main" => "Drizzle",       "description" => I18n.t('weather.313'), "icon" => "09d" },
	  { "id" => 314, "main" => "Drizzle",       "description" => I18n.t('weather.314'), "icon" => "09d" },
	  { "id" => 321, "main" => "Drizzle",       "description" => I18n.t('weather.321'), "icon" => "09d" },
    { "id" => 500, "main" => "Rain",          "description" => I18n.t('weather.500'), "icon" => "10d" },
    { "id" => 501, "main" => "Rain",          "description" => I18n.t('weather.501'), "icon" => "10d" },
	  { "id" => 502, "main" => "Rain",          "description" => I18n.t('weather.502'), "icon" => "10d" },
    { "id" => 503, "main" => "Rain",          "description" => I18n.t('weather.503'), "icon" => "10d" },
	  { "id" => 504, "main" => "Rain",          "description" => I18n.t('weather.504'), "icon" => "10d" },
	  { "id" => 511, "main" => "Rain",          "description" => I18n.t('weather.511'), "icon" => "13d" },
    { "id" => 520, "main" => "Rain",          "description" => I18n.t('weather.520'), "icon" => "09d" },
	  { "id" => 521, "main" => "Rain",          "description" => I18n.t('weather.521'), "icon" => "09d" },
	  { "id" => 522, "main" => "Rain",          "description" => I18n.t('weather.522'), "icon" => "09d" },
	  { "id" => 531, "main" => "Rain",          "description" => I18n.t('weather.531'), "icon" => "09d" },
    { "id" => 600, "main" => "Snow",          "description" => I18n.t('weather.600'), "icon" => "13d" },
	  { "id" => 601, "main" => "Snow",          "description" => I18n.t('weather.601'), "icon" => "13d" },
    { "id" => 602, "main" => "Snow",          "description" => I18n.t('weather.602'), "icon" => "13d" },
	  { "id" => 611, "main" => "Snow",          "description" => I18n.t('weather.611'), "icon" => "13d" },
	  { "id" => 612, "main" => "Snow",          "description" => I18n.t('weather.612'), "icon" => "13d" },
	  { "id" => 613, "main" => "Snow",          "description" => I18n.t('weather.613'), "icon" => "13d" },
	  { "id" => 615, "main" => "Snow",          "description" => I18n.t('weather.615'), "icon" => "13d" },
	  { "id" => 616, "main" => "Snow",          "description" => I18n.t('weather.616'), "icon" => "13d" },
	  { "id" => 620, "main" => "Snow",          "description" => I18n.t('weather.620'), "icon" => "13d" },
	  { "id" => 621, "main" => "Snow",          "description" => I18n.t('weather.621'), "icon" => "13d" },
	  { "id" => 622, "main" => "Snow",          "description" => I18n.t('weather.622'), "icon" => "13d" },
	  { "id" => 701, "main" => "Mist",          "description" => I18n.t('weather.701'), "icon" => "50d" },
	  { "id" => 711, "main" => "Smoke",         "description" => I18n.t('weather.711'), "icon" => "50d" },
	  { "id" => 721, "main" => "Haze",          "description" => I18n.t('weather.701'), "icon" => "50d" },
	  { "id" => 731, "main" => "Dust",          "description" => I18n.t('weather.731'), "icon" => "50d" },
	  { "id" => 741, "main" => "Fog",           "description" => I18n.t('weather.741'), "icon" => "50d" },
	  { "id" => 751, "main" => "Sand",          "description" => I18n.t('weather.751'), "icon" => "50d" },
	  { "id" => 761, "main" => "Dust",          "description" => I18n.t('weather.761'), "icon" => "50d" },
	  { "id" => 762, "main" => "Ash",           "description" => I18n.t('weather.701'), "icon" => "50d" },
	  { "id" => 771, "main" => "Squalls",       "description" => I18n.t('weather.711'), "icon" => "50d" },
	  { "id" => 781, "main" => "Tornado",       "description" => I18n.t('weather.781'), "icon" => "50d" },
    { "id" => 800, "main" => "Clear",         "description" => I18n.t('weather.800'), "icon" => "01d" },
    { "id" => 801, "main" => "Clouds",        "description" => I18n.t('weather.801'), "icon" => "02d" },
    { "id" => 802, "main" => "Clouds",        "description" => I18n.t('weather.802'), "icon" => "03d" },
    { "id" => 803, "main" => "Clouds",        "description" => I18n.t('weather.803'), "icon" => "04d" },
    { "id" => 804, "main" => "Clouds",        "description" => I18n.t('weather.804'), "icon" => "04d" }
  ]

  def self.weather_conditions
   @@weather_conditions
  end 

  def self.get_weather(lat, lon)
    # We check if weather available in database and inside validity
    db_weather = WeatherCall.where(lon: lon, lat: lat).last

    # If available, we return it
    unless db_weather.nil?
      # We check if weather call created inside validity tolerance and same location
      if Time.now.hour - db_weather.created_at.hour <= WEF_CONFIG['default_weather_calls_validity_hours'].to_i &&
        db_weather.created_at.today? &&
        db_weather.lon.round(6) == lon.round(6) &&
        db_weather.lat.round(6) == lat.round(6)
        return db_weather.id
      end
    end

    # If no data present in database, 2 scenarios:
    # 1. If we provide real weather, we call the weather API
    # 2. If we don't provide real weather, we generate fake weather in database for a given lon,lat
    if WEF_CONFIG['fake_weather'] == false
      # True Weather, we call the weather api
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

    else
      # Fake weather, that we create
      fake_weather_json = JSON.generate( create_fake_weather(lat,lon) )

      # Persist in database
      WeatherCall.create(lat: lat,
                         lon: lon,
                         json: fake_weather_json)

    end


    # And we retrive the id of the record in database real or fake
    return  WeatherCall.where(lat: lat).where(lon: lon).pluck(:id).last
  end

  # This method ensures that the weather is compliant with all pilot's preferences
  # Parameters:
  #   user (User):          the user to retrieve it's weather preferences
  #   weather_data (hash):  the result of openweather api call format - daily
  def self.is_weather_pilot_compliant?(user, weather_data)
    pilot_weather_profile = PilotPref.find_by(user_id: user).weather_profile
    pilot_max_ground_wind = PilotPref.find_by(user_id: user).max_gnd_wind_speed

    weather_code_id = weather_data["weather"][0]["id"].to_i
    weather_profiles =  WEF_CONFIG['weather_profiles']
    weather_ok = false

    # The pilot weather profile is "safe"
    if pilot_weather_profile == PilotPref.weather_profiles.keys[0]
      if weather_profiles[0]["safe"].include?(weather_code_id)
        weather_ok = true
      end
    end

    # The pilot weather profile is "adventurous"
    if pilot_weather_profile == PilotPref.weather_profiles.keys[1]
      if weather_profiles[0]["safe"].include?(weather_code_id) or
         weather_profiles[1]["adventurous"].include?(weather_code_id)
        weather_ok = true
      end
    end
    
    # We check if wind speed is above pilot's preferences
    if weather_ok # We weather was already not ok, no need to check the winds
      wind_kts = weather_data["wind_speed"] * 1.9438445
      weather_ok = wind_kts.round(0) <= pilot_max_ground_wind ? true : false
    end

    return weather_ok
  end

  # We require current_user because weather is interpretated following pilot's weather preferences
  def self.forecast(current_user, airport)
    # Variables init
    weather_array = []
    precision  = WEF_CONFIG['default_weather_tile_precision'].to_f

    # We load a Tile in order to retrieve weather information at tile center, not airport coordinates
    tile = WeatherTile.new(current_user, Date.today, precision, nil, nil, airport)
    
    # We load the forecast of outbound airport based on coordinates of origin tile
    weather_call_id = WeatherService::get_weather(tile.lat_center, tile.lon_center)

    # We retrieve weather information from that id
    weather_data = JSON.parse(WeatherCall.find(weather_call_id).json)

    # We load the data in an array
    hash = {}
    (0..7).each do |index|
      weather_ok    = WeatherService::is_weather_pilot_compliant?( current_user, weather_data["daily"][index])
      weather_id    = weather_data["daily"][index]["weather"][0]["id"]
      weather_hash  = WeatherService.weather_conditions.find { |weather| weather["id"] == weather_id }

      hash = { "id"           => weather_id,
               "description"  => weather_hash["description"],
               "icon"         => weather_hash["icon"],
               "wind_speed"   => weather_data["daily"][index]["wind_speed"].round(0),
               "wind_deg"     => weather_data["daily"][index]["wind_deg"].round(0),
               "weather_ok"   => weather_ok
      }
      weather_array.push(hash)
    end
    return weather_array
  end

  private

  def self.create_fake_weather(lon, lat)
    # We gather all available weather codes
    weather_codes_all = @@weather_conditions.map { |weather_condition| weather_condition["id"] }
    
    # Variable init
    random_daily_weather_array = []

    # Create a hash containing today's weather and 7 days forecast
    8.times do |time|
      # Random weather
      random_weather_id = weather_codes_all.sample

      # Load weather description for a given weather id
      weather_description_hash = @@weather_conditions.find { |weather_condition| weather_condition["id"] == random_weather_id }

      # Array of hash
      hash = {
              "wind_speed"  => rand(1.39..8.33), #m/s
              "wind_deg"    => rand(0..359),
              "weather"     =>  [
                                  { "id"          => random_weather_id,
                                    "main"        => weather_description_hash["main"],
                                    "description" => weather_description_hash["description"],
                                    "icon"        => weather_description_hash["icon"]
                                  }
                                ]
             }
      random_daily_weather_array << hash
    end
    
    # We build a json following OpenWeather API 3.0 specs
    hash = {  "lat" => lat,
              "lon" => lon,
              "daily" => random_daily_weather_array
           }
  end
end
