require 'rest-client'

# This module provides weather information
module Weather
  module_function

  # Get weather description hash by code id
  def description(id)
    weather_hash = WEATHER_CODES.find { |entry| entry['id'] == id }
    weather_hash['description'] = I18n.t("weather.#{id}")
    weather_hash
  end

  # Returns a hash following OpenWeather API 3.0 specs 
  #   Provides a forecast for a defined latitude and longitude.
  #   Weather should be stored in cache.
  def read(lat, lon)
    # We generate a key depending on latitude and longitude
    key = "#{lat.round(3)}-#{lon.round(3)}"

    # If key available in cache we retrieve, otherwise api call
    Rails.cache.fetch(key, expires_in: 1.hours) do
      url = 'https://api.openweathermap.org/data/3.0/onecall'
      app_id = Rails.application.credentials[Rails.env.to_sym]
                    .openweathermap.app_id
      JSON.parse(RestClient.get(url,
                                { params:
                                         { lat:,
                                           lon:,
                                           appid: app_id,
                                           exclude: 'current,hourly,minutely',
                                           units: 'metric' } }))
    end
  end
end
