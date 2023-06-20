require "test_helper"

class TripSuggestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get trip_suggestion index" do
    login_as users(:regular_user)
    get trip_suggestions_url
    assert_response :success
  end
end
