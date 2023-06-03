class BlogViewsController < ApplicationController
  def index
    if current_user.role == "admin"
      @blog_views = BlogView.all
      respond_to do |format|
        format.html
        format.csv { send_data @blog_views.to_csv, filename: "blog_views-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
      end
    end
  end
end
