require "application_system_test_case"

class SubscribersTest < ApplicationSystemTestCase
  driven_by :selenium, using: :firefox, screen_size: [1400, 1400]

  test "Subscription shoudl work" do
    visit root_url
    fill_in :name, with: "alex"
    fill_in :email, with: "alex@sky-unlimited.lu"
    check :accept_private_data_policy
    click_on "Submit"
    assert_selector ".alerts", text: "You successfully subscribed to the Newsletter!"
  end
end
