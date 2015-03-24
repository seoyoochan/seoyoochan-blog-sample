class CommentsController < ApplicationController
  include CommentsHelper
  before_action :set_comments, only: [:show, :edit, :like, :unlike, :destroy]
  before_filter :comment_params, only: [:create,:update]
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource

  def index
    @comments = Comment.all
    respond_to do |format|
      format.html {  }
      format.json { render json: @comments }
    end
  end

  def new
    parent = Comment.find_by_id(params[:parent_id])
    @obj = parent.commentable_type.constantize.find(parent.commentable_id)

    if signed_in?
    child_comment = parent.children.build_from(@obj, current_user.id, "")
    @comment = Comment.build_from(@obj, current_user.id, "")
    end

    respond_to do |format|
      format.js
    end
  end

  def create

    if params[:comment][:body].present?
      @comment.user_id = current_user.id
      @comment.created_at = Time.now
      @comment.updated_at = Time.now

      respond_to do |format|
        if @comment.save
          format.html { go_back }
          format.json { render json: @comment, status: :created }
          format.js
        else
          format.html { go_back, flash[:error] = "댓글작성에 실패했습니다." }
          format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
          format.js
        end
      end

    else
      flash[:error] = "비어있는 댓글을 입력할 수 없습니다."
      go_back
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @comment }
    end
  end

  def edit
    thread_obj
    respond_to do |format|
      format.js
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { go_back }
        format.json { render json: @comment }
        format.js
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { go_back }
      format.json { head :no_content }
      format.js
    end
  end

  def like
    respond_to do |format|
      format.js
    end
  end

  def unlike
    respond_to do |format|
      format.js
    end
  end

  private
  def set_comments
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type, :title, :subject, :parent_id, :lft, :rgt)
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = t("unauthorized.#{controller_name}.#{exception.action}")
    go_back
  end
end
