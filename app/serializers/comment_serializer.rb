# class CommentSerializer < ActiveModel::Serializer
#   attributes :id, :commentable_id, :commentable_tye, :title, :body, :subject, :user_id, :parent_id
#
#   belongs_to :commentable, :polymorphic => true
#
#   belongs_to :user
#
#   url [:post, :comment]
# end
