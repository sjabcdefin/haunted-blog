# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :authorize_blog_owner, only: %i[edit update destroy]
  before_action :authorize_secret_blog_access, only: %i[show]
  before_action :reject_random_eyecatch, only: %i[create update]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    if @invalid_random_eyecatch
      redirect_to new_blog_path
      return
    end

    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @invalid_random_eyecatch
      redirect_to edit_blog_path(@blog)
      return
    end

    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end

  def authorize_blog_owner
    return if @blog.user == current_user

    raise ActiveRecord::RecordNotFound
  end

  def authorize_secret_blog_access
    return unless @blog.secret && @blog.user != current_user

    raise ActiveRecord::RecordNotFound
  end

  def reject_random_eyecatch
    @invalid_random_eyecatch = !current_user.premium && blog_params[:random_eyecatch]
  end
end
