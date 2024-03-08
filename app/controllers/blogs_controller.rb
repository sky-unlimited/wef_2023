class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :show, :index ]

  def index
  end

  def show
  end

  def edit
  end

  def new
  end

  def create
  end

end
