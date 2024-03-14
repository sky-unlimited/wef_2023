# This model manages the blog/newsletter
class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show index]
  before_action :set_blog, only: %i[show edit update destroy]

  def index
    if current_user&.admin?
      @blogs = Blog.all.includes(%i[rich_text_content
                                    user
                                    picture_attachment]).order('id DESC')
    else
      @blogs = Blog.where.not(published: false).includes(%i[rich_text_content
                                                          user
                                                          picture_attachment])
                   .order('id DESC')
    end
  end

  def show; end

  def edit; end

  def update
    if @blog.update(blog_input_params)
      redirect_to blog_url(@blog), notice: 'Post was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog = Blog.find_by_id(params[:id])
    if @blog.destroy
      flash.notice = 'Newsletter was deleted'
      redirect_to blogs_path
    else
      render 'index'
    end
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(blog_input_params)
    @blog.user = current_user
    if @blog.save
      redirect_to blog_url(@blog),
                  notice: 'Newsletter was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def blog_input_params
    params.require(:blog).permit(:user, :title, :content, :keywords, :picture,
                                 :published, :scheduled_email, :sent_email)
  end

  def set_blog
    @blog = Blog.find(params[:id])
  end
end
