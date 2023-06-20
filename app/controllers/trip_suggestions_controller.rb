class TripSuggestionsController < ApplicationController
  def index
    @trip_request = TripRequest.where(user_id: current_user.id).order(id: :desc).first
  end
end
