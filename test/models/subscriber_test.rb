require "test_helper"

class SubscriberTest < ActiveSupport::TestCase

  test "Normal subscriber should save" do
    assert subscribers(:subscriber_one).save
  end

  test "Too many attempts on same ip address should not save" do
    Subscriber.new(email: "test@exmple.com", accept_private_data_policy: true).save
    assert_not Subscriber.new(email: "test2@exmple.com", accept_private_data_policy: true).save
  end

  test "Wrong email should not save" do
    assert_not Subscriber.new(email: "test@", accept_private_data_policy: true).save
  end

  test "Private policy not accepted should not save" do
    assert_not Subscriber.new(email: "test@example.com", accept_private_data_policy: false).save
  end
end

