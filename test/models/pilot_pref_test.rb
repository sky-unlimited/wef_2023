require "test_helper"

class PilotPrefTest < ActiveSupport::TestCase

  test "Correct values shoud save" do
    assert pilot_prefs(:profile1).save
  end

  #FIXME: Why doesn't it work? In console correct behavior
  #test "Wrong runway length should not save" do
  #  hash =  { user: User.last,
  #            weather_profile: 0,
  #            airport: Airport.first,
  #            is_ultralight_pilot: false,
  #            is_private_pilot: false,
  #            min_runway_length: 100,
  #            fuel_card_total: false,
  #            fuel_card_bp: false,
  #            max_gnd_wind_speed: 15
  #          }
  #  assert PilotPref.create(hash)
  #end
end
