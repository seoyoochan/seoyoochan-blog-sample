class Limitation < ActiveRecord::Base
  belongs_to :posts
  belongs_to :limits
end
