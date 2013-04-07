json.categories do
  controller.add_rendered_entity(@category)

  json.partial! "categories/show", category: @category

  json.articles do 
    json.array! @articles do |article|
      controller.add_rendered_entity(article)

      json.partial! "articles/show", article: article
    end
  end
end