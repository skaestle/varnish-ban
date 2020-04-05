# frozen_string_literal: true

# fragment cache, using jbuilder caching
json.cache! category do
  json.call(category, :id, :updated_at, :name)
end
