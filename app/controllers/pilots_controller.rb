class PilotsController < ApplicationController
  before_action :set_base_url, only: %i[show]

  def show
    @pilot = Pilot.find(params[:id])
    @user = @pilot.user
    @followers = @user.followers.includes(follower: {pilot: :airport})
    @followings = @user.followings.includes(following: {pilot: :airport})
    @audit_logs = @user.audit_logs
    @visited_airports = @pilot.visited_airports.includes(:airport)
    @pilot_activities = @pilot.user.audit_logs + @visited_airports
    @pilot_activities = @pilot_activities.sort_by(&:created_at).reverse

    @departure_airport = {
      name: @pilot.airport.name,
      icao: @pilot.airport.icao,
      airport_type: @pilot.airport.airport_type,
      geojson: RGeo::GeoJSON.encode(@pilot.airport.geom_point),
      icon_url: helpers.image_url('departure_airport.png')
    }

    @visited_destination_map = @visited_airports.map do |visited_airport|
      airport = visited_airport.airport
      link = "#{@base_url}/#{I18n.default_locale}/airports/#{airport.id}"
      p   airport
      {
        id: airport.id,
        name: airport.name,
        icao: airport.icao,
        airport_type: airport.airport_type,
        geojson: RGeo::GeoJSON.encode(airport.geom_point),
        icon_url: helpers.image_url("small_airport.png"),
        detail_link: link
      }
    end
  end

  def edit
    @pilot = Pilot.find(params[:id])
    @airports = Airport.all
  end

  def update
    @pilot = Pilot.find(params[:id])
    if @pilot.update(pilot_params)
      redirect_to pilot_path(@pilot), notice: 'Profile was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_base_url
    url = request.url
    uri = URI.parse(url)
    @base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
  end

  def pilot_params
    params.require(:pilot).permit(:airport_id, :airport_role, :aircraft_type, :bio)
  end
end
