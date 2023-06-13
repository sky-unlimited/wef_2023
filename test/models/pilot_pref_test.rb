require "test_helper"

class PilotPrefTest < ActiveSupport::TestCase
  test "Default values should save" do
    assert pilot_prefs(:profile2).save
  end

  test "Correct values  shoud save" do
    assert pilot_prefs(:profile1).save
  end

  #FIXME: Why doesn't it work? In console correct behavior
  #test "Wrong runway length should not save" do
  #  hash =  { user: users(:admin_user),
  #            weather_profile: 0,
  #            airport_icao: 0,
  #            min_runway_length: 100,
  #            fuel_card_total: false,
  #            fuel_card_bp: false,
  #            max_gnd_wind_speed: 15
  #          }
  #  assert_not PilotPref.create(hash)
  #end
end
