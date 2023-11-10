# test/mailers/subscribers_mailer_test.rb
require 'test_helper'

class SubscribersMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  def setup
    # Set the default host for the mailer test
    default_url_options[:host] = 'localhost:3000' # Update this with your actual host
  end

  test "subscribed email" do
    # Create a subscriber from the fixture
    subscriber = subscribers(:subscriber_one)

    # Call the mailer method with the necessary parameters
    email = SubscribersMailer.with(subscriber: subscriber, link: "unsubscribe_link").subscribed
    puts email.body

    # Check that the subject is correct
    assert_equal "You are registered to the Newsletter!", email.subject

    # Check that the email is sent to the correct address
    assert_equal [subscriber.email], email.to

    # Check that the email body contains the subscriber's name
    assert_match /#{subscriber.name}/, email.html_part.body.to_s

    # Check that the email body contains the unsubscribe link
    assert_match /unsubscribe_link/, email.html_part.body.to_s

    # Check that the email body contains the root link
    assert_match /#{root_url}/, email.html_part.body.to_s
  end
end

