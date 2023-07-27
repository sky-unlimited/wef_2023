class AddAverageTrueAirspeedToPilotPrefs < ActiveRecord::Migration[7.0]
  def change
    add_column :pilot_prefs, :average_true_airspeed, :integer, null: false, default: 100
  end
end
