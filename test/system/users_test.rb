# Controller tests should respect the default_url_options set in the ApplicationController anyway.
# https://www.youtube.com/watch?v=PtGjHGdJQrQ

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase

  test "Sign in user should work" do
    user = users(:regular_user)
    visit user_session_url
    fill_in "Email", with: user.email
    fill_in "Password", with: "Hello123"
    click_on "Log in"
    assert_selector ".alerts", text: "Signed in successfully."
  end

  test "Sign in incorrect credentials should not work" do
    user = users(:regular_user)
    visit user_session_url
    fill_in "Email", with: user.email
    fill_in "Password", with: "wrong password"
    click_on "Log in"

    assert_selector ".alerts", text: "Invalid Email or password."
  end

  test "A user can require a new password" do
    visit user_session_url
    click_on "Forgot your password?"
    assert_selector "h2", text: "Forgot your password?"
  end

  test "A user can sign-up" do
    visit new_user_registration_url
    fill_in "Email", with: "hannibal.smith@email.com"
    fill_in "Username", with: "username1"
    fill_in "Password", with: "Hello123"
    fill_in "Password confirmation", with: "Hello123"
    click_on "Sign up"

    # Wait for the page to load
    sleep(5)

    assert_selector ".alerts", text: "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
  end
end
