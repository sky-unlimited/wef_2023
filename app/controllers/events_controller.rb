class EventsController < ApplicationController
  def index
    @events = Event.includes(:airport).closest(current_user.base_airport)
  end

  def new
    @event = Event.new
    @airports = Airport.all
  end
end
