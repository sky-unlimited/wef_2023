require "application_system_test_case"

class ContactsTest < ApplicationSystemTestCase
  #FIXME:Doesn't work...
  test "Correct form should save" do
    visit new_contact_url
    fill_in "Email", with: "alex@sky-unlimited.lu"
    fill_in "Description", with: "This is a usefull description od my requirement"
    page.find('#contact_accept_privacy_policy', :visible => false).check
    click_on "Submit"
    assert_selector ".alerts", text: I18n.t("contact.notice.form_sent")
  end
end
