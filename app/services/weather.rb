require 'rest-client'

##
# This class is a service the provides weather information to the app
class Weather
  # Get weather description hash by code id
  def self.description(id)
    weather_hash = WEATHER_CODES.find { |entry| entry['id'] == id }
    weather_hash['description'] = I18n.t("weather.#{id}")
    weather_hash
  end

  # Returns the last weather forecasts for a defined latitude and longitude.
  #   Returns a hash
  #   Weather is stored in cache.
  def self.read(lat, lon)
    # We generate the a depending on latitude and longitude
    key = "#{lat.round(3)}-#{lon.round(3)}"

    # If this key is available in cache, we retrieve the value,
    #   if not we call the API
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
