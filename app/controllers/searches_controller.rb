class SearchesController < ApplicationController
  load_and_authorize_resource

  def new
    @search = Search.new(search_params)
  end

  def create
    @search = Search.new(keywords: params[:search][:keywords], category_id: params[:search][:category_id])
    @search.user_id = current_user.id if signed_in?
    @search.user_id = nil unless signed_in?
    @search.save
    redirect_to @search
  end

  def show
    @search = Search.find(params[:id])
    @posts = Post.search("#{@search.keywords}")
    @category = Category.find(@search.category_id) if @search.category_id
  end

  private
  def search_params
    params.require(:search).permit(:keywords, :category_id, :user_id) if params[:search]
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = t("unauthorized.#{controller_name}.#{exception.action}")
    go_back
  end
end
