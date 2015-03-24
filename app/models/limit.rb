class Limit < ActiveRecord::Base
  resourcify
  # has_many :limitations
  # has_many :posts, through: :limitations
  belongs_to :limitable, polymorphic: true

  def self.limits_group
    { admin: 1, basic: 2, premium: 3, family: 4, lover: 5, me: 6 }
  end

  def self.limitations
    6.times do |n| Limit.find(n+1) end
  end
end
