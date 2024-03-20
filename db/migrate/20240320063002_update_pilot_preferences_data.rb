class UpdatePilotPreferencesData < ActiveRecord::Migration[7.1]
  def up
    Preference.all.each do |preference|
      pilot_pref = PilotPref.find_by(user: preference.pilot.user)
      preference.update!(
        weather_profile: pilot_pref.weather_profile,
        min_runway_length: pilot_pref.weather_profile,
        fuel_card_total: pilot_pref.weather_profile,
        fuel_card_bp: pilot_pref.weather_profile,
        max_gnd_wind_speed: pilot_pref.weather_profile,
        is_ultralight_pilot: pilot_pref.weather_profile,
        is_private_pilot: pilot_pref.weather_profile,
        average_true_airspeed: pilot_pref.weather_profile,
      )
    end
  end
end
