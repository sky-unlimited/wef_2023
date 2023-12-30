require "normalize_country"

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
  def home
    # We load the current covered countries (airport countries)
    @countries_array = []
    distinct_countries = Country.joins(:airports).distinct
    distinct_countries.each do |country|
      @countries_array.push country.code
    end

    # We count the number of amenities available in our database
    @accomodation_count = PoiCatalogue.count(:accommodation)
    @food_count = PoiCatalogue.count(:food) 
    @bus_station_count = PoiCatalogue.count(:bus_station)
    @bike_rental_count = PoiCatalogue.count(:bike_rental)
    @camp_site_count = PoiCatalogue.count(:camp_site)
    @car_rental_count = PoiCatalogue.count(:car_rental)

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
