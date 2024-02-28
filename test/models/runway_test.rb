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

  test "should not save a not given surface type " do
    hash = {  airport: airports(:ellx),
              length_meter: 2000,
              width_meter: 15,
              le_ident: 10,
              he_ident: 28,
              lighted: false }
    record = Runway.new(hash)
    assert_not record.save, "Runway surface not provided"
  end

  test "Runway length equal to zero should not save" do
    hash = {  airport: airports(:ellx),
              length_meter: 0,
              width_meter: 15,
              le_ident: 10,
              he_ident: 28,
              surface: "CON",
              lighted: false }
    record = Runway.new(hash)
    assert_not record.save
  end
end
