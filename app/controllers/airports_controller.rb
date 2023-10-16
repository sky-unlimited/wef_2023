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
      #factory_4326 = RGeo::Geographic.spherical_factory(srid: 4326)
      #point_4326 = RGeo::Feature.cast(osm_point.way, factory_4326)
      point =  { :id => osm_point.id,
                 :name => osm_point.osm_name,
                 :geojson => RGeo::GeoJSON.encode(osm_point.way) }
      @points_array << point
    end
  end
end
