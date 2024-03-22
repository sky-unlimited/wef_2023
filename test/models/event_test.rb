require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "should not save an event where end date is earlier than start date" do
    assert_not events(:invalid_event).save, "End date is earlier than start date"
  end
end
