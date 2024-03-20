class UpdatePilotPreferencesData < ActiveRecord::Migration[7.1]
  def up
    Preference.all.each do |preference|
      pilot_pref = PilotPref.find_by(user: preference.pilot.user)
      preference.update!(
        weather_profile: pilot_pref.weather_profile,
        min_runway_length: pilot_pref.min_runway_length,
        fuel_card_total: pilot_pref.fuel_card_total,
        fuel_card_bp: pilot_pref.fuel_card_bp,
        max_gnd_wind_speed: pilot_pref.max_gnd_wind_speed,
        is_ultralight_pilot: pilot_pref.is_ultralight_pilot,
        is_private_pilot: pilot_pref.is_private_pilot,
        average_true_airspeed: pilot_pref.average_true_airspeed,
      )
    end
  end
end
