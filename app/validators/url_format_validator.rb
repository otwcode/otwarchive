# Validate format of URLs
class UrlFormatValidator < ActiveModel::EachValidator
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
  
  def validate_each(record,attribute,value)
    invalid_url_format_msg = t('lib.invalid_url_error', :default => "does not appear to be a valid URL.")
    unless (value.blank? && options[:allow_blank]) || value =~ @@is_valid_url_format
      record.errors[attribute] << (options[:message] || invalid_url_format_message)
    end
  end
end
