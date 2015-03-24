class Post < ActiveRecord::Base
  include VotesHelper
  include AttrSearchable
  attr_searchable :title, :body
  attr_searchable :comment => "comments.body"

  resourcify
  acts_as_ordered_taggable
  acts_as_ordered_taggable_on :tags
  acts_as_voteable
  acts_as_commentable

  acts_as_url(:slug, url_attribute: :slug)

  belongs_to :user
  has_many :views, as: :viewable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :category

  # has_many :limitations
  # has_many :limits, through: :limitations

  has_many :limits, as: :limitable

  scope :uncategorized, -> { posts.where(category_id: nil) }
  scope :recent, -> { order("posts.updated_at DESC") }
  scope :by_10, -> { limit(10) }

  validates :title, presence: false
  validates :body, presence: true
  validates :slug, presence: true
  validates :slug, uniqueness: true


  def to_param
    "#{slug}"
  end

end