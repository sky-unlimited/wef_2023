require 'normalize_country'

# The pages controller handels the landing page
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    # We load the current covered countries (airport countries)
    @countries_array = WEF_CONFIG['airport_countries_to_import']

    # We apply a low-level caching in order to avoid reloading the counters
    # statistics at ecah page reload
    @poi_counter = Rails.cache.fetch('poi_counter', expires_in: 1.day) do
      {
        accommodation: PoiCatalogue.count(:accommodation),
        food: PoiCatalogue.count(:food),
        bus_station: PoiCatalogue.count(:bus_station),
        bike_rental: PoiCatalogue.count(:bike_rental),
        camp_site: PoiCatalogue.count(:camp_site),
        car_rental: PoiCatalogue.count(:car_rental)
      }
    end

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
