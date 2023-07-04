class CreateWeatherCalls < ActiveRecord::Migration[7.0]
  def change
    create_table :weather_calls do |t|
      t.decimal :lon, null: false
      t.decimal :lat, null: false
      t.text :json

      t.timestamps
    end
  end
end
