require "test_helper"

class FuelStationsControllerTest < ActionDispatch::IntegrationTest
  test "should not get index if not logged in" do
    get fuel_stations_index_url
    assert_response :redirect #to login page
  end
end
