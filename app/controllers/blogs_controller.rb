class BlogsController < ApplicationController
    skip_before_action :authenticate_user!, only: [ :show, :index ]
  # GET blogs
  def index
    @blogs = Blog.all.order(created_at: :desc)
  end

  # GET blogs/1
  def show
    @blog = Blog.find_by_id(params[:id])
    # A cookie is set to know if we have already viewed this page or not
    if cookies[params[:id]].nil?
      blog_view = BlogView.new(blog_id: @blog.id, ip_address: request.remote_ip)
      blog_view.save!
      cookies[params[:id]] = 1
    end
  end

  # GET blogs/new
  def new
    @blog = Blog.new
  end

  # POST blogs/1
  def create
    @blog = Blog.new(blog_input_params)
    @blog.user_id = current_user.id
    if @blog.save
      flash.notice = t('blogs.flash.created')
      redirect_to blogs_path
    else
      render "new", blog: @blog
    end
  end

  # blogs/1/edit
  def edit
    @blog = Blog.find_by_id(params[:id])
  end

  # PATCH/PUT /blogs/1
  def update
    @blog = Blog.find_by_id(params[:id])
    if @blog.update(blog_input_params)
      flash.notice = t('blogs.flash.updated')
      redirect_to blog_path(@blog)
    else
      render "edit", blog: @blog
    end
  end

  def destroy
    @blog = Blog.find_by_id(params[:id])
    if @blog.destroy
      flash.notice = t('blogs.flash.deleted')
      redirect_to blogs_path
    else
      render "show", blog: @blog
    end
  end

  private

  def blog_input_params
    params.require(:blog).permit(:user, :title, :content, :keywords, :picture)
  end
end
