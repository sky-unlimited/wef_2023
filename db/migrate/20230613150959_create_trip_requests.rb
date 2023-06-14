class CreateTripRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :trip_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :airport, null: false, foreign_key: true
      t.datetime :start_date, null:false
      t.datetime :end_date, null: true
      t.integer :trip_mode, null: false
      t.boolean :proxy_food, null: false, default: false
      t.boolean :proxy_fuel, null: false, default: false
      t.boolean :proxy_car_rental, null: false, default: false
      t.boolean :proxy_bike_rental, null: false, default: false
      t.boolean :proxy_camp_site, null: false, default: false
      t.boolean :proxy_hotel, null: false, default: false

      t.timestamps
    end
  end
end
