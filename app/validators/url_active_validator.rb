require 'timeout'
require 'uri'

class UrlActiveValidator < ActiveModel::EachValidator

  # Checks the status of the webpage at the given url
  # To speed things up we ONLY request the head and not the entire page.
  # Bypass check for fanfiction.net, ficbook.net, and bsky.app because of ip block
  def validate_each(record,attribute,value)
    return true if value.match("fanfiction.net") || value.match("ficbook.net") || value.match("bsky.app")
    
    inactive_url_msg = "could not be reached. If the URL is correct and the site is currently down, please try again later."
    inactive_url_timeout = 10 # seconds
    begin
      status = Timeout::timeout(options[:timeout] || inactive_url_timeout) {
        url = Addressable::URI.parse(value)

        env_proxy = ENV["http_proxy"]
        http = if env_proxy
                 proxy = URI(env_proxy)
                 Net::HTTP.new(url.hostname, url.port, proxy.hostname, proxy.port)
               else
                 Net::HTTP.new(url.hostname, url.port)
               end
        http.use_ssl = true if url.scheme == "https"
        response_code = http.start { |h| h.head(url.path.presence || "/").code }
        active_status = %w[200 301 302 307 308]
        active_status.include? response_code
      }
    rescue
      status = false
    end
    record.errors.add(attribute, options[:message] || inactive_url_msg) unless status
  end
    
end
