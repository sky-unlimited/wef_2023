require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "Correct contact form should be accepted" do
    hash = {
      username: "",
      last_name: "lastname",
      first_name: "firstname",
      company: "company",
      email: "test@example.com",
      phone: "+352661466477",
      category: 0,
      description: "This is a full description of my usefull request",
      accept_privacy_policy: true,
      honey_bot: ""
    }
    contact = Contact.new(hash)
    assert contact.save
  end

  test "The bot filling the hidden honeypot should be trapped" do
    hash = {
      username: "",
      last_name: "lastname",
      first_name: "firstname",
      company: "company",
      email: "test@example.com",
      phone: "+352661466477",
      category: 0,
      description: "This is a full description of my usefull request",
      accept_privacy_policy: true,
      honey_bot: "Will the bot be trapped??"
    }
    contact = Contact.new(hash)
    assert_not contact.save
  end

  test "Missing description or too short description should not save" do
    hash = { last_name: "lastname",
             first_name: "firstname",
             company: "",
             email: "test@example.com",
             phone: "",
             category: 0,
             description: "This ...",
             accept_privacy_policy: true,
             honey_bot: "" 
    }
    contact = Contact.new(hash)
    assert_not contact.save
  end

  test "Wrong formatted email should not save" do
    hash = { last_name: "lastname",
             first_name: "firstname",
             company: "",
             email: "test@example",
             phone: "",
             category: 0,
             description: "This is a usefull description of my problem",
             accept_privacy_policy: true,
             honey_bot: "" }
    contact = Contact.new(hash)
    assert_not contact.save
  end

  #test "Wrong formatted phone number should not save" do
  #  hash = { last_name: "lastname",
  #           first_name: "firstname",
  #           company: "",
  #           email: "test@example.com",
  #           phone: "not a phone number",
  #           category: 0,
  #           description: "This is a usefull description of my problem",
  #           accept_privacy_policy: true,
  #           honey_bot: "" }
  #  contact = Contact.new(hash)
  #  assert_not contact.save
  #end
end
