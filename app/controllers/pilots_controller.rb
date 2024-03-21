class PilotsController < ApplicationController
  def show
    @pilot = Pilot.find(params[:id])
  end

  def edit
    @pilot = Pilot.find(params[:id])
    @airports = Airport.all
  end
end
