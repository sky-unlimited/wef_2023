class DropTableWeatherCalls < ActiveRecord::Migration[7.1]
  def change
    drop_table :weather_calls
  end
end
