require "test_helper"

class AirportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
    @airport = airports(:ellx)
  end

  test "should get index" do
    sign_in users(:regular_user)
    get airports_url(locale: I18n.default_locale, id: @user.id)
    assert_response :success
  end

  test "should get show" do
    sign_in users(:regular_user)
    get airports_url(locale: I18n.default_locale, id: @airport)
    assert_response :success
  end
end
