class Search < ActiveRecord::Base
  resourcify
  belongs_to :user
  validates :keywords, presence: true

  def posts
    @posts ||= find_posts
  end

  private
  def find_posts
    posts = Post.order(:updated_at)
    posts = posts.where("title like ?", "%#{keywords}") if keywords.present?
    posts = posts.where(category_id: category_id) if category_id.present?
    posts
  end

end
