class PreferencesController < ApplicationController
  require 'uri'

  # Manages the pilot's preferences
  before_action :set_base_url, only: %i[edit update]
  before_action :load_weather_profiles, only: [:edit]

  def edit
    @preference = current_user.preference
    set_airport_details if @preference.pilot.airport.present?
  end

  def update
    @preference = Preference.find(params[:id])
    set_airport_details if @preference.pilot.airport.present?
    if @preference.update(preference_params)
      flash.notice = t('preferences.saved')
      redirect_to root_path
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def preference_params
    params.require(:preference).permit(:pilot_id,
                                       :is_ultralight_pilot, :is_private_pilot,
                                       :weather_profile, :min_runway_length,
                                       :max_gnd_wind_speed, :min_runway_length,
                                       :fuel_card_total, :fuel_card_bp,
                                       :average_true_airspeed)
  end

  def set_airport_details
    airport = current_user.base_airport
    airport_name = airport.name
    airport_icao = airport.icao
    @airport_full_name = "#{airport_name} (#{airport_icao})"
  end

  def set_base_url
    url = request.url
    uri = URI.parse(url)
    @base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end

  def load_weather_profiles
    profiles_safe        = WEF_CONFIG['weather_profiles'][0]['safe']
    profiles_adventurous = WEF_CONFIG['weather_profiles'][1]['adventurous']

    @array_profile_safe = []
    @array_profile_adventurous = []

    profiles_safe.each do |weather_code|
      @array_profile_safe.push(Weather.description(weather_code))
    end
    profiles_adventurous.each do |weather_code|
      @array_profile_adventurous.push(Weather.description(weather_code))
    end
  end
end
