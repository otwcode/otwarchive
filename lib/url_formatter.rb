require 'uri'
require 'cgi'
require 'addressable/uri'

class UrlFormatter
  
  attr_accessor :url
  
  def initialize(url)
    @url = url || ""
  end
  
  def original
    url
  end
  
  # Remove anchors and query parameters, preserve sid parameter for eFiction sites
  def minimal (input = url)
    uri = Addressable::URI.parse(input)
    queries = CGI::parse(uri.query) unless uri.query.nil?
    if queries.nil?
      return input.gsub(/(\?|#).*$/, '')
    else
      queries.keep_if { |k,v| ['sid'].include? k }
      querystring = ('?' + URI.encode_www_form(queries)) unless queries.empty?
      return input.gsub(/(\?|#).*$/, '') << querystring.to_s
    end
  end

  def minimal_no_protocol_no_www
    minimal.gsub(/https?:\/\/(www\.)?/, "")
  end
  
  def no_www
    minimal.gsub(/(https?):\/\/www\./, "\\1://")
  end
  
  def with_www
    minimal.gsub(/(https?):\/\//, "\\1://www.")
  end

  def with_http
    minimal.gsub(/https?:\/\//, "").prepend("http://")
  end

  def with_https
    minimal.gsub(/https?:\/\//, "").prepend("https://")
  end

  def encoded
    minimal URI::Parser.new.escape(url)
  end
  
  def decoded
    URI::Parser.new.unescape(minimal)
  end
  
  # Adds http if not present, downcases the host and hyphenates spaces
  # Extracted from story parser class
  # Returns a Generic::URI
  def standardized
    uri = URI.parse(url)
    uri = URI.parse('http://' + url) if uri.class.name == "URI::Generic"
    uri.host = uri.host.downcase.tr(" ", "-")
    uri
  end

end
