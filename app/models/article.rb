# frozen_string_literal: true

require 'ban_entity_from_varnish'

class Article < ActiveRecord::Base
  include BanEntityFromVarnish
  has_and_belongs_to_many :categories
end
