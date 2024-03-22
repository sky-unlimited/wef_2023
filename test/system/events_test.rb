require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  test "User cannot see events if they don't sign in" do
    visit root_path
    assert_no_selector "h1", text: "Events near you"
  end

  test "User who signed in can see events" do
    user = users(:regular_user)
    visit root_path
    login_as(user)

    assert_selector "h1", text: "Events near you"
  end

  test "Admin can see create and edit button on events page" do
    admin = users(:admin_user)
    visit events_path
    login_as(admin)

    assert_selector "a.btn.btn-primary", text: "Add Event"
  end

  test "User cannot see create button on events page" do
    user = users(:regular_user)
    login_as(user)
    visit events_path

    assert_no_selector "a.btn.btn-primary", text: "Add Event"
  end

  def login_as(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "Hello123"
    click_on "Log in"
  end
end
