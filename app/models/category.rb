class Category < ActiveRecord::Base
  resourcify
  belongs_to :user
  has_many :posts, dependent: :nullify

  validates :name, presence: true
end
