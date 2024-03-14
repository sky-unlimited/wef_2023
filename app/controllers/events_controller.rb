class EventsController < ApplicationController
  def index
    @events = Event.includes(:airport).closest(current_user.base_airport)
  end
end
