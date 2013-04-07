json.categories do
    controller.add_rendered_entity(@category)

    json.id @category.id
    json.name @category.name

    json.articles do 
        json.array! @articles do |article|

            controller.add_rendered_entity(article)
            json.id article.id
            json.title article.title
            json.lead article.lead
            json.text article.text
        end
    end
end