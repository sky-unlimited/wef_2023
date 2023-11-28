require "test_helper"

class FuelStationTest < ActiveSupport::TestCase
  test "Correct fuel station should save" do
    fs = fuel_stations(:fs_ellx)
    assert fs.save
  end

  test "Second fuel station on existing airport should fail" do
    hash = { airport: airports(:ellx),
            provider: 0,
            status: 0,
            fuel_avgas_100ll: true }
    fs = FuelStation.create(hash)
    assert_not fs.save
  end

  test "Email is not mandatory test should not fail" do
    hash = { airport: airports(:lfsw),
            provider: 0,
            status: 0,
            fuel_avgas_100ll: true }
    fs = FuelStation.create(hash)
    assert fs.save
  end

  test "Phone is not mandatory test should not fail" do
    hash = { airport: airports(:lfsw),
            provider: 0,
            status: 0,
            fuel_avgas_100ll: true,
            email: "test@example.com" }
    fs = FuelStation.create(hash)
    assert fs.save
  end
end
