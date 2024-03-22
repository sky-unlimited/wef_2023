require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
    @event = events(:valid_event)
  end

  test "should get index" do
    sign_in @regular_user
    get events_path
    assert_response :success
  end

  test "should redirect new event page for regular user" do
    sign_in @regular_user
    get new_event_path
    assert_redirected_to root_path
  end

  test "should get new event page for admin user" do
    sign_in @admin_user
    get new_event_path
    assert_response :success
  end

  test "should redirect edit event page for regular user" do
    sign_in @regular_user
    get edit_event_path(id: 1)
    assert_redirected_to root_path
  end

  test "should get edit event page for admin user" do
    sign_in @admin_user
    get edit_event_path(id: 1)
    assert_response :success
  end
end
