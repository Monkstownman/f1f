json.extract! user_thing_lookup, :id, :user_id, :thing_id, :created_at, :updated_at
json.url user_thing_lookup_url(user_thing_lookup, format: :json)