# Manages the pilot preferences
class PilotPref < ApplicationRecord
  belongs_to :user
  belongs_to :airport

  saf = 'activerecord.attributes.pilot_pref.weather_profile_options.safe'
  adv = 'activerecord.attributes.pilot_pref.weather_profile_options.adventurous'
  enum :weather_profile, { I18n.t(saf) => 0,
                           I18n.t(adv) => 1 }

  validates :user, presence: true
  validates :min_runway_length, numericality: { in: 150..1500 }
  validates :max_gnd_wind_speed, numericality: { in: 15..45 }
  validates :average_true_airspeed, numericality: { in: 0..250 }

  validate :pilot_should_have_at_least_one_licence

  after_create :subscribe_newsletter

  def pilot_should_have_at_least_one_licence
    return unless is_ultralight_pilot == false && is_private_pilot == false

    errors.add(':is_private_pilot', 'Please choose at least one licence')
  end

  # Based on a daily weather data, returns if weather compliant with pilot prefs
  def weather_pilot_compliant?(daily_data)
    weather_profiles = WEF_CONFIG['weather_profiles']
    is_compliant = false
    weather_id = daily_data['weather'][0]['id'].to_i

    # The pilot weather profile is "safe"
    if weather_profile == PilotPref.weather_profiles.keys[0] &&
       weather_profiles[0]['safe'].include?(weather_id)
      is_compliant = true
    end

    # The pilot weather profile is "adventurous"
    if weather_profile == PilotPref.weather_profiles.keys[1] &&
       (weather_profiles[0]['safe'].include?(weather_id) ||
        weather_profiles[1]['adventurous'].include?(weather_id))
      is_compliant = true
    end
    # We check if wind speed is above pilot's preferences
    if is_compliant # We weather was already not ok, no need to check the winds
      wind_kts = daily_data['wind_speed'] * 1.9438445
      is_compliant = wind_kts.round(0) <= max_gnd_wind_speed
    end

    is_compliant
  end

  def enrich_weather_forecast(weather_data)
    weather_data['daily'].each do |weather|
      weather['is_pilot_compliant'] =
        weather_pilot_compliant?(weather)
    end
    weather_data
  end

  def subscribe_newsletter
    hash = { email: user.email,
             accept_private_data_policy: true,
             honey_bot: '' }
    new_subscriber = Subscriber.new(hash)
    new_subscriber.save
  end
end
