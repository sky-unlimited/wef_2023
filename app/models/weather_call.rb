class WeatherCall < ApplicationRecord
  validates :lon  , presence: true
  validates :lat  , presence: true
  validates :json , presence: true
end
