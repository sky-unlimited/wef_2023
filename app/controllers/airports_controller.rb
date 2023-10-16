require 'rgeo'
require 'rgeo/proj4'

class AirportsController < ApplicationController
  # GET /airports
  def index
    @airports = Airport.all
  end

  # GET /airports/1
  def show
    @airport = Airport.find(params[:id])
    @runways = @airport.runways

    # Link to Visual Airport Chart if available
    # France
    if @airport.icao.match?(/^LF..$/) #VAC only for ICAO airports
      aip_cycle = WEF_CONFIG['sia_current_cycle'].freeze
      @vac_link = "https://www.sia.aviation-civile.gouv.fr/dvd/eAIP_#{aip_cycle}/Atlas-VAC/PDF_AIPparSSection/VAC/AD/AD-2.#{@airport.icao}.pdf"
    end

    # Load the oms_points
    @points_array = []
    osm_points = OsmPoint.where(airport_id: @airport.id)
    osm_points.each do |osm_point|
      # Convert projection to geography
      geography = RGeo::CoordSys::Proj4.create(4326) #geography
      projection = RGeo::CoordSys::Proj4.create(3857) #projection
      x,y = RGeo::CoordSys::Proj4.transform_coords(projection, geography, osm_point.way.x, osm_point.way.y, nil)

      point =  {  :id => osm_point.id,
                  :name => osm_point.osm_name,
                  :latitude => y,
                  :longitude => x }
      @points_array << point
    end
  end
end
