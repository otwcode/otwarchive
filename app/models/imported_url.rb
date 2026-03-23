# Url of an imported work
class ImportedUrl < ApplicationRecord
  belongs_to :Work

  def initialize(url)
    self.original = url
  end

  before_save :set_formatted_urls
  def set_formatted_urls
    formatter = UrlFormatter.new(:original)
    self.minimal = formatter.minimal
    self.minimal_no_protocol_no_www = formatter.minimal_no_protocol_no_www
    self.no_www = formatter.no_www
    self.with_www = formatter.with_www
    self.with_http = formatter.with_http
    self.with_https = formatter.with_https
    self.encoded = formatter.encoded
    self.decoded = formatter.decoded
  end
end
