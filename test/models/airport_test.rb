require "test_helper"

class AirportTest < ActiveSupport::TestCase
    test "should not create an existing airport -> fixture" do
      assert airports(:ellx).save
    end

    test "should not create a military airport" do
      airport_hash = { icao: "LFKS", name: "Solenzara (BA 126) Air Base", city: "Solenzara", country: countries(:france), latitude: 41.924400329589844, longitude: 9.406000137329102, altitude: 28, airport_type: "medium_airport" }
      record = Airport.new(airport_hash)
      assert_not record.save
    end

    test "should not create a heliport" do
      airport_hash = { icao: "LFPI", name: "Paris Issy-les-Moulineaux", city: "Paris", country: countries(:france), latitude: 48.833302, longitude: 2.27278, altitude: 112, airport_type: "heliport" }
      record = Airport.new(airport_hash)
      assert_not record.save
    end

    test "should create a white listed airport" do
      airport_hash = { icao: "LFJY", name: "Chambley Air Base", city: "Chambley", country: countries(:france), latitude: 49.025501, longitude: 5.87607, altitude: 866, airport_type: "small_airport" }
      record = Airport.new(airport_hash)
      assert record.save
    end
end
