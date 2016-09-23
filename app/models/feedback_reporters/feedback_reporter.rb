class FeedbackReporter
  include HtmlCleaner
  require 'url_formatter'

  attr_accessor :title,
                :description,
                :email,
                :language,
                :category,
                :username,
                :url

  def initialize(attrs = {})
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
    # We're sending the XML data via a URL to our Support ticket service. The
    # URL needs to be Percent-encoded so that everything shows up correctly on
    # the other end. (https://en.wikipedia.org/wiki/Percent-encoding)
    encoded_xml = CGI.escape(xml.to_str)
    HTTParty.post("#{ArchiveConfig.NEW_BUGS_SITE}#{project_path}",
                  body: "&xml=#{encoded_xml}")
  end

  def xml
    view = ActionView::Base.new(Rails.root.join('app', 'views'))
    view.assign({ report: self })
    view.render(template: template)
  end

  def project_path
    self.class::PROJECT_PATH
  end
end
