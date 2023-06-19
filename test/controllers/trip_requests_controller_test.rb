require "test_helper"

class TripRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trip_request = trip_requests(:trip_request_correct)
  end

  test "should get new" do
    login_as users(:regular_user)
    get new_trip_request_url
    assert_response :success
  end

  test "should get edit" do
    login_as users(:regular_user)
    get edit_trip_request_url(locale: I18n.default_locale, id: @trip_request)
    assert_response :success
  end

end
