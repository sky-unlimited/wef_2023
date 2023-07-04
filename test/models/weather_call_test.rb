require "test_helper"

class WeatherCallTest < ActiveSupport::TestCase
  test "Correct weather call should save" do
    assert weather_calls(:ellx).save
  end

  test "Incomplete weather call should not save" do
    wc = WeatherCall.new
    assert_not wc.save
  end
end
