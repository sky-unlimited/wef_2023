class VisitedAirportsController < ApplicationController
  def create
    @airport = Airport.find(params[:airport_id])
    @pilot = current_user.pilot
    @visited_airport = VisitedAirport.new(pilot: @pilot, airport: @airport)
    if @visited_airport.save
      redirect_to airport_path(@airport), notice: 'Airport added to your visited list'
    else
      redirect_to airport_path(@airport), alert: 'Could not add airport to your visited list. Try again.'
    end
  end

  def destroy
    @visited_airport = VisitedAirport.find(params[:id])
    if @visited_airport.destroy
      redirect_to airport_path(@visited_airport.airport), notice: 'Airport removed from your visited list'
    else
      redirect_to airport_path(@visited_airport.airport), alert: 'Could not remove airport from your visited list. Try again.'
    end
  end
end
