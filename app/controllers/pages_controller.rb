class PagesController < ApplicationController
  def home

  end

  def  blog
    @posts = Post.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
    @category = Category.all
  end
end
