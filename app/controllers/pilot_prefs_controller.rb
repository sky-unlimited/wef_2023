require 'uri'

class PilotPrefsController < ApplicationController
  before_action :set_base_url, only: [:new, :create, :edit, :update]
  before_action :load_weather_profiles, only: [ :edit]

  def edit
    @pilot_pref = current_user.pilot_pref
    set_airport_details if @pilot_pref.airport_id.positive?
  end

  def update
    @pilot_pref = PilotPref.find(params[:id])
    set_airport_details if @pilot_pref.airport_id.positive?
    if @pilot_pref.update(pilot_pref_params)
      flash.notice = t('pilot_prefs.saved') 
      redirect_to root_path
    else
      render "edit", status: :unprocessable_entity
    end
  end

  private

  def pilot_pref_params
    params.require(:pilot_pref).permit(:user_id, :airport_id, :is_ultralight_pilot, :is_private_pilot, :weather_profile, :min_runway_length, :max_gnd_wind_speed, :min_runway_length, :fuel_card_total, :fuel_card_bp)
  end
  
  def set_airport_details
    airport = Airport.find(@pilot_pref.airport_id)
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
    profiles_safe        = WEF_CONFIG['weather_profiles'][0]["safe"]
    profiles_adventurous = WEF_CONFIG['weather_profiles'][1]["adventurous"]

    @array_profile_safe = []
    @array_profile_adventurous = []

    profiles_safe.each do |weather_code|
      @array_profile_safe.push(WeatherService.find_weather_description_by_id(weather_code))
    end
    profiles_adventurous.each do |weather_code|
      @array_profile_adventurous.push(WeatherService.find_weather_description_by_id(weather_code))
    end
  end
end
