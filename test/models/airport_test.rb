require "test_helper"

class AirportTest < ActiveSupport::TestCase
    test "should not create an existing airport -> fixture" do
      assert airports(:ellx).save
    end

    test "should not create a military airport" do
      airport_hash = { icao: "LFKS", name: "Solenzara (BA 126) Air Base", city: "Solenzara", country: countries(:france), latitude: 41.924400329589844, longitude: 9.406000137329102, altitude: 28, airport_type: "medium_airport", ourairports_id: 10000 }
      record = Airport.new(airport_hash)
      assert_not record.save
    end

    test "should not create a iglider field  airport" do
      airport_hash = { icao: "ELUS", name: "Useldange Glider Field", city: "Useldange", country: countries(:luxembourg), latitude: 41.924400329589844, longitude: 9.406000137329102, altitude: 28, airport_type: "small_airport", ourairports_id: 10001 }
      record = Airport.new(airport_hash)
      assert_not record.save
    end

    test "should not create a heliport" do
      airport_hash = { icao: "LFPI", name: "Paris Issy-les-Moulineaux", city: "Paris", country: countries(:france), latitude: 48.833302, longitude: 2.27278, altitude: 112, airport_type: "heliport", ourairports_id: 10002 }
      record = Airport.new(airport_hash)
      assert_not record.save
    end

    test "should create a white listed airport" do
      airport_hash = { icao: "LFJY", name: "Chambley Air Base", city: "Chambley", country: countries(:france), latitude: 49.025501, longitude: 5.87607, altitude: 866, airport_type: "small_airport", ourairports_id: 10003 }
      record = Airport.new(airport_hash)
      assert record.save
    end

    test "ourairports_id should be unique" do
      airport_hash = { icao: "LFJZ", name: "Chambley test", city: "Chambley", country: countries(:france), latitude: 49.025501, longitude: 5.87607, altitude: 866, airport_type: "small_airport", ourairports_id: 2563 }
      record = Airport.new(airport_hash)
      assert_not record.save
    end
end
