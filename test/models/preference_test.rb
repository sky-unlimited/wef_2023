require "test_helper"

class PreferenceTest < ActiveSupport::TestCase
  test "Correct values shoud save" do
    assert preferences(:profile_ok).save
  end

  test "No pilot licence shoud not save" do
    assert_not preferences(:wrong_licence).save, "Pilot needs at least one pilot licence"
  end

  test "Wrong runway length should not save" do
    hash =  { pilot: pilots(:regular_pilot),
              weather_profile: 0,
              is_ultralight_pilot: false,
              is_private_pilot: true,
              min_runway_length: 100,
              fuel_card_total: false,
              fuel_card_bp: false,
              max_gnd_wind_speed: 15
            }
    record = Preference.new(hash)
    assert_not record.save, "Runway length below limit"
  end

  test "Wind above max limit should not save" do
    hash =  { pilot: pilots(:regular_pilot),
              weather_profile: 0,
              is_ultralight_pilot: false,
              is_private_pilot: true,
              min_runway_length: 150,
              fuel_card_total: false,
              fuel_card_bp: false,
              max_gnd_wind_speed: 50
            }
    record = Preference.new(hash)
    assert_not record.save, "Max wind speed over limit"
  end

end
