require "normalize_country"

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
  def home
    # We load the current covered countries (airport countries)
    @countries_array = WEF_CONFIG['airport_countries_to_import']

    # We count the number of amenities available in our database
    # Those counters are loaded only at server start and available
    # through config/initializers/constants.rb
    @accomodation_count = COUNT_ACCOMODATION
    @food_count         = COUNT_FOOD 
    @bus_station_count  = COUNT_BUS_STATION
    @bike_rental_count  = COUNT_BIKE_RENTAL
    @camp_site_count    = COUNT_CAMP_SITE
    @car_rental_count   = COUNT_CAR_RENTAL

    # We set variables needed for airport searcher
    @base_url = set_base_url
    @locale   = set_locale
  end

  def set_base_url
    url = request.url
    uri = URI.parse(url)
    @base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end

  def set_locale
    @locale = I18n.locale
  end
end
