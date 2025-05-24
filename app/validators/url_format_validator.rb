# Validate format of URLs
class UrlFormatValidator < ActiveModel::EachValidator

  # will be validated with active it if works
  # just do a fast and dirty check. 
  def validate_each(record,attribute,value)
    return true if (value.blank? && options[:allow_blank]) 
    # http (optional s) :// domain . tld (optional port) / anything
    regexp = /^https?:\/\/[_a-z\d\-]+\.[._a-z\d\-]+(:\d+)?\/?.+/i
    unless value.match regexp
      record.errors.add(attribute, options[:message] || :invalid)
    end

    begin
      Addressable::URI.heuristic_parse(value)
    rescue Addressable::URI::InvalidURIError
      record.errors.add(attribute, options[:message] || :invalid)
    end
  end
end
