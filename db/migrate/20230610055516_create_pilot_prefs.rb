class CreatePilotPrefs < ActiveRecord::Migration[7.0]
  def change
    create_table :pilot_prefs do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :weather_profile, default: 0, null: false
      t.integer :airport_icao, default: 0, null: false
      t.integer :min_runway_length, default: 250, null: false
      t.boolean :fuel_card_total, default: 0, null: false
      t.boolean :fuel_card_bp, default: 0, null: false
      t.integer :max_gnd_wind_speed, default: 15, null: false

      t.timestamps
    end
  end
end
