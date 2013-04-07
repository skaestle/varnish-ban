class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter :set_rendered_entities_headers, :set_cache_headers
  attr_writer :expiration_time

  def expiration_time
    @expiration_time ||= 1.day
  end

  def rendered_entities
    @rendered_entities ||= {}
  end

  def add_rendered_entity(entity)
    return unless entity

    key = entity.class.to_s.downcase.parameterize.pluralize

    self.rendered_entities[key] ||= []
    self.rendered_entities[key] << entity
  end

  private
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
