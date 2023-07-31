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
    @accomodation_count = 0
    amenities = ['hostel', 'hotel', 'chalet', 'motel', 'guest_house']
    @accomodation_count += OsmPoint.where(amenity: amenities).count
    @accomodation_count += OsmLine.where(amenity: amenities).count
    @accomodation_count += OsmPolygone.where(amenity: amenities).count

    @restaurants_count = 0
    amenities = ['restaurant', 'fast-food']
    @restaurants_count += OsmPoint.where(amenity: amenities).count
    @restaurants_count += OsmLine.where(amenity: amenities).count
    @restaurants_count += OsmPolygone.where(amenity: amenities).count

    @bus_stations_count = 0
    amenities = ['bus_station', 'bus_stop']
    @bus_stations_count += OsmPoint.where(amenity: amenities).count
    @bus_stations_count += OsmLine.where(amenity: amenities).count
    @bus_stations_count += OsmPolygone.where(amenity: amenities).count

    @bicycle_rental_count = 0
    amenities = ['bicycle_rental']
    @bicycle_rental_count += OsmPoint.where(amenity: amenities).count
    @bicycle_rental_count += OsmLine.where(amenity: amenities).count
    @bicycle_rental_count += OsmPolygone.where(amenity: amenities).count

    @camp_sites_count = 0
    amenities = ['camp_site']
    @camp_sites_count += OsmPoint.where(amenity: amenities).count
    @camp_sites_count += OsmLine.where(amenity: amenities).count
    @camp_sites_count += OsmPolygone.where(amenity: amenities).count

    @bars_count = 0
    amenities = ['bar', 'cafe']
    @bars_count += OsmPoint.where(amenity: amenities).count
    @bars_count += OsmLine.where(amenity: amenities).count
    @bars_count += OsmPolygone.where(amenity: amenities).count
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
