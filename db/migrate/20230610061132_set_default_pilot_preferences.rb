class SetDefaultPilotPreferences < ActiveRecord::Migration[7.0]
  def up
    User.find_each do |user|
      #user.create_pilot_pref(weather_profile: :safe,
      #                       airport_icao: :all,
      #                       min_runway_length: 250,
      #                       fuel_card_total: false,
      #                       fuel_card_bp: false,
      #                       max_gnd_wind_speed: 15)
      #user.create_pilot_pref(user: user)
      p = PilotPref.new
      p.user = user
      p p.valid?
      p.save!
    end
  end

  def down
    PilotPref.destroy_all
  end
end
