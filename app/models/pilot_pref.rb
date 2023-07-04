class PilotPref < ApplicationRecord
  belongs_to :user
  belongs_to :airport

  enum :weather_profile, { I18n.t('activerecord.attributes.pilot_pref.weather_profile_options.safe') => 0,
                           I18n.t('activerecord.attributes.pilot_pref.weather_profile_options.adventurous') => 1 }

  validates :user, presence: true
  validates :min_runway_length, numericality: { in: 150..1500 }
  validates :max_gnd_wind_speed, numericality: { in: 15..45 }

end
