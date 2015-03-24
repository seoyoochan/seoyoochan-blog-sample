module VotesHelper
  def vote_count
    Vote.where(voteable_id: self.id).size
  end
end