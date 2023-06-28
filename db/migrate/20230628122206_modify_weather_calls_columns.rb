class ModifyWeatherCallsColumns < ActiveRecord::Migration[7.0]
  def change
    change_column :weather_calls, :lon, :decimal, precision: 4, scale: 2, null: false
    change_column :weather_calls, :lat, :decimal, precision: 4, scale: 2, null: false
  end
end
