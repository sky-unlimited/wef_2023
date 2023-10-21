require 'rgeo'
require 'rgeo/proj4'
require 'rgeo-geojson'

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

    # Load the osm_points
    @points_array = []
    osm_points = OsmPoint.where(airport_id: @airport.id)
    osm_points.each do |osm_point|
      # Convert projection to geography
      geography   = RGeo::CoordSys::Proj4.create(4326)
      projection  = RGeo::CoordSys::Proj4.create(3857)
      x,y = RGeo::CoordSys::Proj4.transform_coords(projection, geography, osm_point.way.x, osm_point.way.y, nil)

      point =  {  :id => osm_point.id,
                  :name => osm_point.osm_name,
                  :latitude => y,
                  :longitude => x }
      @points_array << point
    end

    # Load osm_polygons but represented as points based on centroid
    @polygones_array = []
    osm_polygones = OsmPolygone.where(airport_id: @airport.id)
    osm_polygones.each do |osm_polygone|
      # We first deduct the centroid of thr polygone in order to display it as a marker
      polygone_centroid = osm_polygone.way.centroid

      # Convert projection to geography
      geography   = RGeo::CoordSys::Proj4.create(4326)
      projection  = RGeo::CoordSys::Proj4.create(3857)
      x,y = RGeo::CoordSys::Proj4.transform_coords(projection, geography, polygone_centroid.x, polygone_centroid.y, nil)

      point =  {  :id => osm_polygone.id,
                  :name => osm_polygone.osm_name,
                  :latitude => y,
                  :longitude => x }
      @points_array << point
    end
  end
end
