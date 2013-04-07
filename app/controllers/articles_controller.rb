class ArticlesController < ApplicationController
  def index
    @category = Category.find(params['category_id'])
    @articles = @category.articles
  end
end
