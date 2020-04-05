# frozen_string_literal: true

class Module
  def core_extension(method)
    if method_defined?(method)
      warn "WARNING: Possible conflict with extension:\
      #{self}##{method} already exists"
    else
      yield
    end
  end
end

class String
  core_extension('varnish_ban_header_name') do
    def varnish_ban_header_name
      downcase.parameterize.pluralize
    end
  end
end
