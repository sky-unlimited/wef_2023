class Destinations
  def initialize(trip_request)
    @trip_request = trip_request
    @flyzone_departure_day = nil
    @flyzone_return_day = nil
    @flyzone_common = nil
    @airports_matching_criterias = nil
    @airports_flyzone_common = nil
    @airports_top_destinations = nil

    create_flyzones

  end

  private

  def create_flyzones
  end
end
