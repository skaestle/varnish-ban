json.article do 
  controller.add_rendered_entity(@article)

  json.partial! "articles/show", article: @article
end