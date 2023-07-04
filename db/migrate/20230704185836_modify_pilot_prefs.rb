class ModifyPilotPrefs < ActiveRecord::Migration[7.0]
  def change
    # Remove the airport_icao column
    remove_column :pilot_prefs, :airport_icao

    # Add the new columns
    add_column :pilot_prefs, :is_ultralight_pilot, :boolean, default: false, null: false
    add_column :pilot_prefs, :is_private_pilot, :boolean, default: false, null: false
    add_reference :pilot_prefs, :airport, foreign_key: true
  end
end
