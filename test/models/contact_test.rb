require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "Correct contact form should be accepted" do
    assert contacts(:contact_ok).save 
  end

  test "The bot fulfilling the hidden honeypot should be trapped" do
    assert_not contacts(:contact_bot).save 
  end

  test "Missing description or too short description should not save" do
    hash = { last_name: "lastname",
             first_name: "firstname",
             company: "",
             email: "test@example.com",
             phone: "",
             category: 1,
             description: "This is ...",
             accept_privacy_policy: true,
             ip_address: "141.94.17.140",
             honey_pot: "" }
    contact = Contact.new(hash)
    assert_not contact.save
  end

  test "Wrong formatted email should not save" do
    hash = { last_name: "lastname",
             first_name: "firstname",
             company: "",
             email: "test@example",
             phone: "",
             category: 1,
             description: "This is a usefull description of my problem",
             accept_privacy_policy: true,
             ip_address: "141.94.17.140",
             honey_pot: "" }
    contact = Contact.new(hash)
    assert_not contact.save
  end

  test "Wrong formatted phone number should not save" do
    hash = { last_name: "lastname",
             first_name: "firstname",
             company: "",
             email: "test@example.com",
             phone: "not a phone number",
             category: 1,
             description: "This is a usefull description of my problem",
             accept_privacy_policy: true,
             ip_address: "141.94.17.140",
             honey_pot: "" }
    contact = Contact.new(hash)
    assert_not contact.save
  end
end
