class Api::V1::AirportsController < ApplicationController
  skip_before_action :authenticate_user!

  def find
    sql_query = <<~SQL
      name ILIKE :query 
      OR icao ILIKE :query 
      OR local_code ILIKE :query
    SQL

    render json: Airport.where(sql_query, query: "%#{params[:query]}%").limit(10)
  end
end
