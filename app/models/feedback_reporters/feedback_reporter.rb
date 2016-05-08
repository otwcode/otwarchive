class FeedbackReporter
  include HtmlCleaner

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
    HTTParty.post("#{ArchiveConfig.BUGS_SITE}",
      body: "&xml=#{xml}"
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
