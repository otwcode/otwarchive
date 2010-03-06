# Custom validations
# 
# Currently added: a modified version of http://github.com/henrik/validates_url_format_of
# 
ActiveRecord::Base.class_eval do 

  require 'timeout'
  require 'uri'
    
  @@ipv4_part = /\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]/ # 0-255
  @@is_valid_url_format = %r{
\A
https?:// # http:// or https://
([^\s:@]+:[^\s:@]*@)? # optional username:pw@
( (xn--)?[^\W_]+([-.][^\W_]+)*\.[a-z]{2,6}\.? | # domain (including Punycode/IDN)...
#{@@ipv4_part}(\.#{@@ipv4_part}){3} ) # or IPv4
(:\d{1,5})? # optional port
([/?]\S*)? # optional /whatever or ?whatever
\Z
}iux
  
  @@is_valid_url_format_msg = t('lib.invalid_url_error', :default => "does not appear to be a valid URL.")
  @@is_active_url_msg = t('lib.inactive_url_error', :default => "could not be reached. If the URL is correct and the site is currently down, please try again later.")
  @@is_active_url_timeout = 15 # seconds
  @@is_canonical_tag_msg = t('initializers.canonical_tag_error', :default => "include the following noncanonical tags: {{value}}")
  
  # Here's where we define the added validations
  def self.validates_url_format_of(*attr_names)
    configuration = { 
                :with => @@is_valid_url_format,
                :message => @@is_valid_url_format_msg }
    configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
    validates_format_of attr_names, configuration
  end
  
  def self.validates_url_active_status_of(*attr_names)
    configuration = { 
                      :message => @@is_active_url_msg, 
                      :timeout => @@is_active_url_timeout}
    configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

    validates_each attr_names do |model, attr_name, value|
      if !value.blank?
        begin
          model.errors.add(attr_name, configuration[:message]) if !url_active?(value, configuration[:timeout])
        rescue Timeout::Error
          model.errors.add(attr_name, configuration[:message])
        end
      elsif !(configuration[:allow_nil] || configuration[:allow_blank])
        model.errors.add(attr_name, configuration[:message])
      end
    end
  end

  ### extra helper functions 

  # Make urls consistent
  def reformat_url(url)
    url = "http://" + url if url && url.length > 0 && /http/.match(url[0..3]).nil?
    url.chop if url.last == "/"
    url  
  end
  
  # Checks the status of the webpage at the given url
  # To speed things up we ONLY request the head and not the entire page.
  def self.url_active?(url, timeout_in_seconds=60)
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
      
end
