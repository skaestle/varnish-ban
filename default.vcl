vcl 4.1;

backend default {
  # connect to rails server
  .host = "127.0.0.1";
  .port = "3000";
}

sub vcl_recv {
  # let the cookiemonster loose!
  unset req.http.cookie;
}

sub vcl_deliver {
  # we don't want the client to cache the JSON resources
  set resp.http.Cache-Control = "max-age=0, private";

  # unset the headers, thus remove them from the response the client sees
  # unset resp.http.X-Articles;
  # unset resp.http.X-Category;

  # Just for debugging: return cache hit/miss
  if (obj.hits > 0) {
    set resp.http.X-Varnish-Cache = "HIT";
  } else {
    set resp.http.X-Varnish-Cache = "MISS";
  }
}

sub vcl_backend_response {
 set beresp.ttl = 1h;
 set beresp.grace = 10h;

 return (deliver);
}
