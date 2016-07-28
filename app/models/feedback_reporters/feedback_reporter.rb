class FeedbackReporter
  include HtmlCleaner
  require 'url_formatter'

  attr_accessor :title, 
    :description,
    :email,
    :language,
    :category,
    :username

  def initialize(attrs={})
    attrs.each_pair do |key, val|
      self.send("#{key}=", val)
    end
  end

  def title
    strip_html_breaks_simple(@title)
  end

  def description
    strip_html_breaks_simple(@description)
  end

  def send_report!
    # We're sending the XML data via a URL to our Support ticket service. The URL needs to be Percent-encoded so that
    # everything shows up correctly on the other end. (https://en.wikipedia.org/wiki/Percent-encoding)
    encoded_xml = CGI.escape(xml.to_str)
    HTTParty.post("#{ArchiveConfig.BUGS_SITE}",
      body: "&xml=#{encoded_xml}"
    )
  end

  def send_abuse_report!
    encoded_xml = CGI.escape(xml.to_str)
    HTTParty.post("#{ArchiveConfig.ABUSE_REPORTS_SITE}",
      body: "&xml=#{encoded_xml}"
    )

  end

  def xml
    view = ActionView::Base.new(Rails.root.join("app", "views"))
    view.assign({report: self})
    view.render(template: template)
  end

  def project_id
    self.class::PROJECT_ID
  end
end
