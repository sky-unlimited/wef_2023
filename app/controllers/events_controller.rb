class EventsController < ApplicationController
  def index
    @events = Event.includes(:airport).closest(current_user.base_airport)
  end

  def new
    @event = Event.new
    @airports = Airport.all
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to events_path, notice: 'Event was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :airport_id, :start_date, :end_date, :kind, :image_link, :url)
  end
end
