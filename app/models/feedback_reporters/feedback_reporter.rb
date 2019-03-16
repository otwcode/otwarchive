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
    add_break_between_paragraphs(@description)
  end

  def send_report!
    HTTParty.post("#{ArchiveConfig.NEW_BUGS_SITE}#{project_path}",
                  body: "&xml=#{URI.encode_www_form_component(xml.to_str)}")
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
