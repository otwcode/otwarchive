require 'timeout'
require 'uri'

class UrlActiveValidator < ActiveModel::EachValidator

  # Checks the status of the webpage at the given url
  # To speed things up we ONLY request the head and not the entire page.
  # Bypass check for fanfiction.net because of ip block
  def validate_each(record,attribute,value)
    return true if value.match("fanfiction.net")
    inactive_url_msg = "could not be reached. If the URL is correct and the site is currently down, please try again later."
    inactive_url_timeout = 10 # seconds
    Rails.logger.debug "HERE IS STEP ONE"
    begin
      Rails.logger.debug "HERE IS STEP TWO"
      status = Timeout::timeout(options[:timeout] || inactive_url_timeout) {
        url = URI.parse(value)
        response_code = Net::HTTP.start(url.host, url.port) {|http| http.head(url.path.blank? ? '/' : url.path).code}
        active_status = %w(200 301 302)
        active_status.include? response_code
      }
      Rails.logger.debug "HERE IS STEP THREE"
    rescue
      Rails.logger.debug "HERE IS STEP FOUR"
      status = false
    end
    Rails.logger.debug "HERE IS STEP FIVE"
    record.errors[attribute] << (options[:message] || inactive_url_msg) unless status
  end
    
end
