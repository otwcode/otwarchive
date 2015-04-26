class FeedbackReporter
  include HtmlCleaner

  attr_accessor :title, 
    :description, 
    :category, 
    :email

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
    HTTParty.post("#{ArchiveConfig.BUGS_SITE}/projects/#{project_id}/bugs",
      headers: { 
        "Content-Type" => "application/xml", 
        "Accept" => "application/xml" 
      },
      basic_auth: {
        username: ArchiveConfig.BUGS_USER,
        password: ArchiveConfig.BUGS_PASSWORD
      },
      body: xml
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
