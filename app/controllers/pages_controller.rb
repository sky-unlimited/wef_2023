require "normalize_country"
require 'poi_catalogue'

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
    @beverage_count = PoiCatalogue.count(:beverage)
  end

  def console
    unless current_user.role == "admin" 
      render_404
    end
    #Link to chartkick tutorial: https://gorails.com/episodes/charts-with-chartkick-and-groupdate
  end

  private

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end
end
