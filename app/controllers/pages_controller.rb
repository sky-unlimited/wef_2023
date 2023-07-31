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
