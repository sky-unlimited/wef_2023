require "test_helper"

class AirportTest < ActiveSupport::TestCase
    test "should not create a military airport" do
      assert_not  airports(:ellx_military).save
    end

    test "should not create a heliport" do
      assert_not  airports(:ellx_heliport).save
    end

    test "should create an airport" do
      assert airports(:ellx).save
    end
end
