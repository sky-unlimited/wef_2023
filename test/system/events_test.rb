require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
  end

  test "User cannot see events if they don't sign in" do
    visit root_path
    assert_no_selector "h1", text: "Events near you"
  end

  test "User who signed in can see events" do
    sign_in @regular_user
    visit root_path

    assert_selector "h1", text: "Events near you"
  end

  test "Admin can see create and edit button on events page" do
    sign_in @admin_user
    visit events_path

    assert_selector "a.btn.btn-primary", text: "Add Event"
  end

  test "User cannot see create button on events page" do
    sign_in @regular_user
    visit events_path

    assert_no_selector "a.btn.btn-primary", text: "Add Event"
  end
end
