require "test_helper"

class CountryTest < ActiveSupport::TestCase
    test "Countries presence" do
      assert Country.first.present?
    end

    test "should create a country" do
      assert countries(:france).save
    end

    test "should not create a country - incorrect code" do
      assert_not countries(:incorrect1).save
    end

    test "should not create a country - no country name" do
      assert_not countries(:incorrect2).save
    end

    test "should not create a country - incorrect continent" do
      assert_not countries(:incorrect3).save
    end

    test "should not create a country - inexistant continent" do
      assert_not countries(:incorrect4).save
    end
end
