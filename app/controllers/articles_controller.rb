# frozen_string_literal: true

class ArticlesController < ApplicationController
  def index
    @category = Category.find(params['category_id'])
    @articles = @category.articles
  end

  def show
    @article = Article.find(params['id'])
  end
end
