json.array!(@policies) do |policy|
  json.extract! policy, :id, :type, :body, :version, :user_id
  json.url policy_url(policy, format: :json)
end
