# frozen_string_literal: true

json.article do
  # adds the category to the rendered entity collection
  controller.add_rendered_entity(@article)

  json.partial! 'articles/show', article: @article
end
