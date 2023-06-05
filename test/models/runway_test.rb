require "test_helper"

class RunwayTest < ActiveSupport::TestCase
  test "should create a runway" do
    assert runways(:ellx_runway).save
  end

  test "should create first runway for Epernay (France)" do
    assert runways(:lfsw_runway_1).save
  end

  test "should create second runway for Epernay (France)" do
    assert runways(:lfsw_runway_2).save
  end
end
