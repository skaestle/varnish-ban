categories = Category.create( [{name: 'science'}, {name: 'politics'}] )
categories.each do |cat|
  5.times do 
    cat.articles << Article.create( [{title: "title", lead: "lead", text: "text"}] )
  end
end

categories[1].articles << categories[0].articles.first 
categories[0].articles << categories[1].articles.first 

categories.each { |cat| cat.save }