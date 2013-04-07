class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter :set_rendered_entities_headers, :set_cache_headers
  attr_writer :expiration_time

  # expiration_time for the cache, default is 1 day  
  def expiration_time
    @expiration_time ||= 1.day
  end

  def rendered_entities
    @rendered_entities ||= {}
  end

  # files the given entity under its class to the hash
  def add_rendered_entity(entity)
    return unless entity

    key = entity.class.to_s.varnish_ban_header_name

    self.rendered_entities[key] ||= []
    self.rendered_entities[key] << entity
  end

  private
  
  # uses the built up hash and outputs it as HTTP-Header
  def set_rendered_entities_headers
    self.rendered_entities.each do |key, entities|
      entity_ids = entities.map(&:id).map(&:to_s).join(',')
      response.headers['X-' + key] = entity_ids
    end
  end

  def set_cache_headers
    response.headers['Cache-Control'] = "max-age=#{self.expiration_time}, private"
  end
end
