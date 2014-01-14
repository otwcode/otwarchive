require 'uri'

class UrlFormatter
  
  attr_accessor :url
  
  def initialize(url)
    @url = url || ""
  end
  
  def original
    url
  end
  
  # Remove anchors and query parameters
  def minimal
    url.gsub(/\?.*$/, "").gsub(/\#.*$/, "")
  end
  
  def no_www
    url.gsub(/http:\/\/www\./, "http://")
  end
  
  def with_www
    url.gsub(/http:\/\//, "http://www.")
  end
  
  def encoded
    URI.encode(minimal)
  end
  
  def decoded
    URI.decode(minimal)
  end
  
  # Adds http if not present and downcases the host
  # Extracted from story parser class
  def standardized
    clean_url = URI.parse(url)
    clean_url = URI.parse('http://' + url) if clean_url.class.name == "URI::Generic"
    clean_url.host.downcase!
    clean_url.to_s
  end
  
end