# frozen_string_literal: true

# fragment cache, using jbuilder caching
json.cache! article do
  json.call(article, :id, :updated_at, :title, :lead, :text)
end
