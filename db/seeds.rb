# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


categories = Category.create( [{name: 'science'}, {name: 'politics'}] )
categories.each do |cat|
  5.times do 
    cat.articles << Article.create( [{title: "title", lead: "lead", text: "text"}] )
  end
  cat.save
end
