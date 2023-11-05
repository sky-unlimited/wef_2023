require "test_helper"

class SubscriberTest < ActiveSupport::TestCase

  test "Normal subscriber should save" do
    subscriber = subscribers(:subscriber_one)
    assert subscriber.save
  end

  test "Wrong email should not save" do
    assert_not Subscriber.new(name: "John", email: "test@", accept_private_data_policy: true).save
  end

  test "Private policy not accepted should not save" do
    assert_not Subscriber.new(name: "John", email: "test@example.com", accept_private_data_policy: false).save
  end
end

