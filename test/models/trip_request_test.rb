require "test_helper"

class TripRequestTest < ActiveSupport::TestCase
  test "Fixture trip_request one should save" do
    assert trip_requests(:trip_request_correct).save
  end

  test "start_date_in_past should not save" do
    assert_not trip_requests(:start_date_in_past).save
  end

  test "end_date_before_start_date should not save" do
    assert_not trip_requests(:end_date_before_start_date).save
  end

  test "wrong enum should not save" do
    assert_not trip_requests(:wrong_enum).save
  end
end
