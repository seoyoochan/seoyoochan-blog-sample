class PostsController < ApplicationController
  include ActionView::Helpers::TextHelper # to use 'truncate' method

  before_action :set_post, only: [:show, :edit, :update, :destroy, :like, :unlike]
  before_filter :post_meta_info, only: [:show]
  before_filter :authenticate_user!, except: [:index, :show]

  load_and_authorize_resource

  def index
    if params[:search]
      # @posts = Post.search(params[:search])
      @posts = Post.where(title: "#{params[:search]}")
      respond_to do |format|
        format.html { redirect_to }
        # format.json { render json: @res }
      end
    else
      @posts = Post.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
      @category = Category.all
    end
  end

  def show
    @obj = @post
    @comment = Comment.build_from(@post, current_user.id, "") if signed_in?
    @comments = @post.comment_threads

    # Count Views
    if signed_in?
      @post.views.create(user_id: current_user.id, created_at: Time.now, updated_at: Time.now, ip: current_user.current_sign_in_ip) if (@post.views.where(user_id: current_user.id).blank?) && (@post.views.where(ip: current_user.current_sign_in_ip).blank?)
    else
      @post.views.create(user_id: @cached_guest_user.id, created_at: Time.now, updated_at: Time.now, ip: @cached_guest_user.current_sign_in_ip) if (@post.views.where(user_id: @cached_guest_user.id).blank?) && (@post.views.where(ip: @cached_guest_user.current_sign_in_ip).blank?)
    end

    if request.path != post_path(@post)
      redirect_to @post, status: :moved_permanently
    end
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def like
    if current_user.voted_on?(@post)
      flash[:warning] = "이미 좋아요를 했습니다."
    else
      current_user.vote_for(@post)
      go_back
    end
  end

  def unlike
    if current_user.voted_on?(@post)
      current_user.unvote_for(@post)
      go_back
    else
      flash[:warning] = "이미 좋아요를 취소했습니다."
    end
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user

    respond_to do |format|
      if @post.save
        limitations
        format.html { redirect_to @post }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end


  private
  def set_post
    # @post = Post.find(params[:id])
    @post = Post.find_by_slug(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :tag_list, :category_id, :published, :slug, :limits => [], :limit_ids => [])
  end

  def post_meta_info
    @post_meta_published_time = @post.created_at
    @post_meta_updated_time = @post.updated_at
    @post_meta_category = "#{@post.category.name}" if @post.category.present?
    @post_meta_title = "[#{@post_meta_category}] " + "#{HTMLEntities.new.decode(@post.title)}" + "- seoyoochan.com"
    @post_meta_description = "#{truncate(Sanitize.clean(@post.body), length: 200)}".strip
    @post_meta_img = "#{Nokogiri::HTML(@post.body).css("img").map { |i| i["src"] }.first}" if @post.body.include? "<img src"
    @post_meta_tag = @post.tag_list.join(",") if @post.tag_list.present?
  end

  def limitations
    params[:post][:limit_ids].each do |e|
      Limit.create(name: e, limitable_type: "Post", limitable_id: @post.id) if @post && e.present?
    end
  end


  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = t("unauthorized.#{controller_name}.#{exception.action}")
    go_back
  end

end
