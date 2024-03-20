class MovePilotPrefData < ActiveRecord::Migration[7.1]
  def up
    PilotPref.all.each do |pilot_pref|
      pilot = Pilot.create!(airport: pilot_pref.airport, user: pilot_pref.user)
    end
  end

  def down
    Pilot.destroy_all
  end
end
