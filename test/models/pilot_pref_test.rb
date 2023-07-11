require "test_helper"

class PilotPrefTest < ActiveSupport::TestCase

  test "Correct values shoud save" do
    assert pilot_prefs(:profile_ok).save
  end

  test "No pilot licence shoud not save" do
    assert_not pilot_prefs(:wrong_licence).save, "Pilot needs at least one pilot licence"
  end

  test "Wrong runway length should not save" do
    hash =  { user: users(:regular_user),
              weather_profile: 0,
              airport: airports(:ellx),
              is_ultralight_pilot: false,
              is_private_pilot: true,
              min_runway_length: 100,
              fuel_card_total: false,
              fuel_card_bp: false,
              max_gnd_wind_speed: 15
            }
    record = PilotPref.new(hash)
    assert_not record.save, "Runway length below limit"
  end

  test "Wind above max limit should not save" do
    hash =  { user: users(:regular_user),
              weather_profile: 0,
              airport: airports(:ellx),
              is_ultralight_pilot: false,
              is_private_pilot: true,
              min_runway_length: 150,
              fuel_card_total: false,
              fuel_card_bp: false,
              max_gnd_wind_speed: 50
            }
    record = PilotPref.new(hash)
    assert_not record.save, "Max wind speed over limit"
  end
end
