require "test_helper"

class TestMailerTest < ActionMailer::TestCase
  test "hello" do
    mail = TestMailer.hello
    assert_equal "Test from Weekend Fly!", mail.subject
    assert_equal ["team@weekend-fly.com"], mail.to
    assert_equal ["team@weekend-fly.com"], mail.from
    #assert_match "Hi", mail.body.encoded
  end

end
