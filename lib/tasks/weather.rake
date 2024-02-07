require 'rest-client'

namespace :weather do
  desc 'Update the weather in cache through an API call'
  task update: :environment do
    require "#{Rails.root}/config/environment"

    # Configuration variables
    left_limit  = WEF_CONFIG['weather_tiles_left_limit'].to_f.round(3)
    right_limit = WEF_CONFIG['weather_tiles_right_limit'].to_f.round(3)
    upper_limit = WEF_CONFIG['weather_tiles_upper_limit'].to_f.round(3)
    lower_limit = WEF_CONFIG['weather_tiles_lower_limit'].to_f.round(3)
    precision   = WEF_CONFIG['default_weather_tile_precision'].to_f
    expire_hour = WEF_CONFIG['weather_cache_expire_hour'].to_i
    cache = ActiveSupport::Cache::MemCacheStore.new(
                                  expires_in: expire_hour.hours)

    (left_limit..right_limit - 1).step(precision) do |lon|
      (lower_limit..upper_limit - 1).step(precision) do |lat|
        # variables
        lon_center = (lon + (precision / 2)).round(3)
        lat_center = (lat + (precision / 2)).round(3)
        key = "#{lat_center}-#{lon_center}"
        json = Hash.new
        url = 'https://api.openweathermap.org/data/3.0/onecall'
        app_id = Rails.application.credentials[Rails.env.to_sym]
                      .openweathermap.app_id
        params = { params:
                         { lat: lat_center,
                           lon: lon_center,
                           appid: app_id,
                           exclude: 'current,hourly,minutely',
                           units: 'metric' } }

        # api call
        json = JSON.parse(RestClient.get(url, params))

        # Write in cache
        cache.write(key, json)
      end
    end
  end
end
