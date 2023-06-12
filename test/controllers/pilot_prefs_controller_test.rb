require "test_helper"

class PilotPrefsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get pilot_prefs_edit_url
    assert_response :success
  end
end
