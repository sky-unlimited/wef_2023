class PilotPref < ApplicationRecord
  belongs_to :user

  enum weather_profile: [ :safe, :adventurous ]
  enum airport_icao: [ :both, :icao_only ]

  validates :user, presence: true
  validates :min_runway_length, numericality: { in: 150..1500 }
  validates :max_gnd_wind_speed, numericality: { in: 15..45 }

end
