require "application_system_test_case"

class SubscribersTest < ApplicationSystemTestCase

  test "Subscription should work" do
    visit root_url
    fill_in :email, with: "alex@sky-unlimited.lu"
    check :accept_private_data_policy
    click_on "Submit"
    assert_selector ".alerts", text: "You successfully subscribed to the Newsletter!"
  end
end
