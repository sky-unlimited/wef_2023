class TripRequestsController < ApplicationController
  def new
    @trip_request = TripRequest.new
    @trip_request.user = current_user
  end

  def create
  end

  def edit
  end

  def update
  end
end
