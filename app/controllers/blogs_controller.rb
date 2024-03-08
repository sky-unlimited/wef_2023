# This model manages the blog/newsletter
class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show index]

  def index; end

  def show; end

  def edit; end

  def new
    @blog = Blog.new
  end

  def create; end
end
