require "test_helper"

class SubscriberTest < ActiveSupport::TestCase

  test "Normal subscriber should save" do
    assert subscribers(:subscriber_one).save
  end

  test "Already registered email should not save" do
    assert_not Subscriber.new(email: "john.smith@example.com", accept_private_data_policy: true).save
  end

  test "Wrong email should not save" do
    assert_not Subscriber.new(email: "test@", accept_private_data_policy: true).save
  end

  test "Private policy not accepted should not save" do
    assert_not Subscriber.new(email: "test@example.com", accept_private_data_policy: false).save
  end

  test "Filled honey bot field should not save" do
    assert_not Subscriber.new(email: "test@example.com", accept_private_data_policy: true, honey_bot: "I'm trapped").save
  end
end

