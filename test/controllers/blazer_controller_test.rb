require "test_helper"

class BlazerControllerTest < ActionDispatch::IntegrationTest
  test "Normal user should not access the admin page" do
    sign_in users(:regular_user)
    get blazer_url
    assert_response :missing
  end

  test "Not logged in user should not access the admin page" do
    get blazer_url
    assert_response :redirect
  end

  test "Admin user should not access the admin page" do
    sign_in users(:admin_user)
    get blazer_url
    assert_response :success
  end

end
