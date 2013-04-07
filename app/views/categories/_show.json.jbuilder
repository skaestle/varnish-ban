# fragment cache, using jbuilder caching
json.cache! category do
  json.(category, :id, :updated_at, :name)
end