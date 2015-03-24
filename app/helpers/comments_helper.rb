module CommentsHelper
  def comment_obj_helper
    if params["controller"] == "comments" && params["action"] == "new"
      @comment.parent_id = params["parent_id"]
      @comment
    else
      @comment
    end
  end

  def comment_arg_helper
    if (params["controller"] == "posts" && params["action"] == "show") || (params["controller"] == "comments" && params["action"] == "new")
      @obj.id
    else
      @comment.id
    end
  end

  def comment_method_helper
    if params["controller"] == "comments" && params["action"] == "edit"
      :put
    else
      :post
    end
  end

  def comment_url_helper(param)
    if params["controller"] == "comments" && params["action"] == "edit"
      comment_update_post_path(param)
    else
      comments_create_post_path(param)
    end
  end

  def reply_indicator(parent_id)
    "<span class='reply_indicator'>#{name_mapper(User.find(Comment.find(parent_id).user_id))}</span>".html_safe || nil
  end

  def namer(parent_id)
    name_mapper(User.find(Comment.find(parent_id).user_id))
  end

  def thread_obj
    @obj = @comment.commentable_type.constantize.find(@comment.commentable_id)
  end
end
