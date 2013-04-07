class Article < ActiveRecord::Base
  include BanEntityFromVarnish

  attr_accessible :lead, :text, :title
  has_and_belongs_to_many :categories
end
