require 'timeout'
require 'uri'

module UrlHelpers
  # Checks the status of the webpage at the given url
  # To speed things up we ONLY request the head and not the entire page.
  def url_active?(url, timeout_in_seconds=60)
    Timeout::timeout(timeout_in_seconds) {
      begin
        url = URI.parse(url)
        response_code = Net::HTTP.start(url.host, url.port) {|http| http.head(url.path.blank? ? '/' : url.path).code}
        active_status = %w(200 301 302)
        active_status.include? response_code
      rescue
        false
      end
    }
  end
  
  # Make urls consistent
  def reformat_url(url)
    url = "http://" + url if url && url.length > 0 && /http/.match(url[0..3]).nil?
    url.chop if url.last == "/"
    url  
  end
  
end