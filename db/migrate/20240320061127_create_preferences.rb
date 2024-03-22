class CreatePreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :preferences do |t|
      t.references :pilot, null: false, foreign_key: true
      t.integer :weather_profile, default: 0, null: false
      t.integer :min_runway_length, default: 250, null: false
      t.boolean :fuel_card_total, default: 0, null: false
      t.boolean :fuel_card_bp, default: 0, null: false
      t.integer :max_gnd_wind_speed, default: 15, null: false
      t.boolean :is_ultralight_pilot, default: false, null: false
      t.boolean :is_private_pilot, default: true, null: false
      t.integer :average_true_airspeed, default: 100, null: false

      t.timestamps
    end
  end
end
