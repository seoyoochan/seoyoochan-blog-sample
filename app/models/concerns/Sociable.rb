class Sociable
	def self.call(mapper, options)
		mapper.resources :comments, options
		mapper.resources :categories, options
		mapper.resources :tags, options
	end
end