# frozen_string_literal: true

json.categories do
  # adds the category to the rendered entity collection
  controller.add_rendered_entity(@category)

  json.partial! 'categories/show', category: @category

  json.articles do
    json.array! @articles do |article|
      # adds the article to the rendered entity collection
      controller.add_rendered_entity(article)

      json.partial! 'articles/show', article: article
    end
  end
end
