varnish-ban
===========

This Rails project is a proof-of-concept to leverage varnish caching of dynamic content with active banning by the Rails application itself. It uses HTTP-Headers to be able to easily figure out which caches need to be invalidated. Thanks to the guys at https://github.com/russ/lacquer for the Varnish Telnet Client.

## Installing varnish

1.  Install varnish via homebrew
2.  Start it: sudo /usr/local/sbin/varnishd -f /Users/sascha/projects/varnish-ban/default.vcl -a 127.0.0.1:80 -s file,/tmp,500M -T 0.0.0.0:6082 -S none

Please be aware that this configuration is not meant for production. With this configuration varnish will allow anyone with access to `localhost` to telnet into it without any authentication.

## Setting up the project

1.  checkout the repository
2.  bundle install
3.  rake db:setup
4.  rails s

## Seeing it work

1.  curl --head http://localhost/categories/1/articles.json

    See the HTTP-Headers (X-Articles, X-Categories); See how Age counts up
2.  Now change an article and see how the changes propagate through the varnish cache

    curl will now show the Age reset, and of course you're gonna see the changes in the browser too

```
curl --head http://localhost/categories/1/articles.json
HTTP/1.1 200 OK
Cache-Control: max-age=86400, private
X-Categories: 1
X-Articles: 1,2,3,4,5,6
Content-Type: application/json; charset=utf-8
X-Ua-Compatible: IE=Edge
Etag: "408fb88f2f65b4974948f2dd9a039839"
X-Request-Id: ae8ee176dc6a636772f5d0fdd20daf0b
X-Runtime: 0.024485
Server: WEBrick/1.3.1 (Ruby/1.9.3/2012-04-20)
Content-Length: 624
Accept-Ranges: bytes
Date: Sun, 07 Apr 2013 23:30:54 GMT
X-Varnish: 412126710 412126705
Age: 631
Via: 1.1 varnish
Connection: keep-alive
```


Resources that work:

* http://localhost/categories/1/articles.json (having articles 1-6)
* http://localhost/categories/2/articles.json (having articles 1, 6-10)
* http://localhost/articles/1.json (a single article)

They all get banned according to the article that as changed

## How it is accomplished

When an article is saved, an after_save hook calls the banning
``` ruby
require 'ban_entity_from_varnish'
class Article < ActiveRecord::Base
  include BanEntityFromVarnish

  has_and_belongs_to_many :categories
end
```

``` ruby
require 'varnish'

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
```

The application_controller.rb is handling the HTTP-Header creation
``` ruby
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
```

The method #add_rendered_entity(entity) must be called from the templates
``` ruby
json.categories do
  # adds the category to the rendered entity collection
  controller.add_rendered_entity(@category)

  json.partial! "categories/show", category: @category

  json.articles do
    json.array! @articles do |article|
      # adds the article to the rendered entity collection
      controller.add_rendered_entity(article)

      json.partial! "articles/show", article: article
    end
  end
end
```

## Gotchas

* This is a proof-of-concept, thus some errors should be expected. There are no tests.
* The Regex used to ban the caches will not handle low IDs very well. The project I used this approach on uses MongoDB IDs (http://docs.mongodb.org/manual/reference/object-id/) so does not have this issue.
* The Rails caching is pretty weak. Only the partials are cached in a fragment cache. I was not able to find a better way to build up the rendered_entities cache then by calling them from the template. Thus this needs to be executed whenever the template is rendered.
