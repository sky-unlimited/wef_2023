class TripSuggestionsController < ApplicationController
  def index
    # We load the current user last trip request
    @trip_request = TripRequest.where(user_id: current_user.id).order(id: :desc).first

    # We load all airports markers
    @airports_array = []
    airports = Airport.all
    airports.each do |airport|
      @airports_array.push({ :name => airport.name,
                            :icao => airport.icao,
                            :airport_type => airport.airport_type,
                            :geojson => RGeo::GeoJSON.encode(airport.lonlat)
      })
    end


    # We check the weather at departure airport both for start date and return date (if provided)
      # If one of the checked dates is below user's acceptance threshold we display a message and next days weather
      # We exit the process
    # We define the elastic weather for departure date
    # We define the elastic weather for return date
    # We combine the 2 in a fly zone ST_Intersection -> https://chat.openai.com/share/c725d3ab-16f3-42f1-8ca6-972038393e93
    # We display it on a Leaflet map.
  end
end
