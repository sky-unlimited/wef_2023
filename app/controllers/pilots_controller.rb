class PilotsController < ApplicationController
  def show
    @pilot = Pilot.find(params[:id])
    @visited_airports = @pilot.visited_airports.includes(:airport).order('visited_airports.created_at DESC')
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

  def pilot_params
    params.require(:pilot).permit(:airport_id, :airport_role, :aircraft_type, :bio)
  end
end
