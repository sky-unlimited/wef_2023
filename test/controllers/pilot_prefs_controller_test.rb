require "test_helper"

class PilotPrefsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
  end

  test "should get edit" do
    #login_as users(:regular_user)
    sign_in users(:regular_user)
    get edit_pilot_pref_url(locale: I18n.default_locale, id: @user.id)
    assert_response :success
  end
end
