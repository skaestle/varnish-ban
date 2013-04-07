# module that adds an after_save hook which will ban 
# the entity from varnish
module BanEntityFromVarnish
  extend ActiveSupport::Concern
  
  included do
    after_save :queue_url_refresh

    private
    def queue_url_refresh
      Varnish.ban_header(self.class.to_s, id)
    end
  end
end
