class View < ActiveRecord::Base
  resourcify
  belongs_to :viewable, polymorphic: true
end
