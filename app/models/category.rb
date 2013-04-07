class Category < ActiveRecord::Base
  include BanEntityFromVarnish
  
  attr_accessible :name
  has_and_belongs_to_many :articles
end
