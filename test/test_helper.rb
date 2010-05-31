require 'test/unit'
require 'net/http'

module TestHelper
  
  def assert_success(url)
    response = get_response(url)
    assert response.is_a?(Net::HTTPSuccess), "Request to #{url} failed with #{response}"
  end
  
  def assert_redirects(origin_url, target_url)
    url = origin_url
    while (response = get_response(url)) && response.is_a?(Net::HTTPRedirection)
      url = response['Location']
    end
    assert response.is_a?(Net::HTTPSuccess), "Request to #{url} failed with #{response}"
    assert_equal(target_url, url, "Request to #{origin_url}")
  rescue SocketError => e
    raise Test::Unit::AssertionFailedError.new("Request to #{url} failed with exception #{e}")
  end
  
  def get_response(url)
    Net::HTTP.get_response(URI.parse(url))
  end
  
  def jamesmead_org(path)
    "http://jamesmead.#{tld}#{path}"
  end
  
  def floehopper_org(path)
    "http://floehopper.#{tld}#{path}"
  end
  
  def blog_floehopper_org(path)
    "http://blog.floehopper.#{tld}#{path}"
  end
  
  def www_floehopper_org(path)
    "http://www.floehopper.#{tld}#{path}"
  end
  
  def feeds_floehopper_org(path)
    "http://feeds.floehopper.#{tld}#{path}"
  end
  
  def feeds_jamesmead_org(path)
    "http://feeds.jamesmead.#{tld}#{path}"
  end
  
  def feeds_feedburner_com(path)
    "http://feeds.feedburner.com#{path}"
  end
  
  def feed_url
    feeds_jamesmead_org('/floehopper-blog')
  end
  
  def tld
    ENV["TLD"] || "local"
  end
  
  def old_article_path
    "/articles/2009/11/02/activerecord-model-class-name-clash"
  end
  
  def new_article_path
    "/blog/2009-11-02-activerecord-model-class-name-clash"
  end
  
end