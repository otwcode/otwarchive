class AbuseReport < ActiveRecord::Base
  validates_presence_of :comment
  validates_presence_of :url
  validates :email, :email_veracity => {:allow_blank => true}
  attr_accessor :cc_me
  validates :email, :presence => {:message => ts("cannot be blank if requesting an emailed copy of the Abuse Report")}, :if => "email_copy?"
  validate :work_is_not_over_reported

  scope :by_date, order("created_at DESC")

  attr_protected :comment_sanitizer_version

  # if the URL ends like "works/123", add a / at the end
  # if the URL contains "works/123?", remove the parameters and add a /
  # work_is_not_over_reported uses the / so "/works/1234" isn't a match for "/works/123"
  before_validation :clean_work_url, on: :create
  def clean_work_url
    if url.match(/(works\/\d+)$/)
      self.url = url + "/"
    elsif url.match(/(works\/\d+\?)/)
      self.url = url.split("?").first + "/"
    else
      url
    end
  end

  def email_copy?
   cc_me == "1"
  end

  app_url_regex = Regexp.new('^https?:\/\/(www\.)?' + ArchiveConfig.APP_HOST, true)
  validates_format_of :url, :with => app_url_regex, :message => ts('does not appear to be on this site.')

  # Category names for form
  CATEGORIES = [
    ["Children's Online Privacy and Protection Act", 11468],
    ["Reproduction of copyrighted or trademarked material (unfair use)", 11469],
    ["Illegal or non-fanwork content", 11471],
    ["Plagiarism", 11470],
    ["Open Doors", 11516],
    ["Harassment", 11473],
    ["Next-of-kin claim", 11514],
    ["Personal information (outing)", 11472],
    ["Spam or commercial promotion", 11515],
    ["Inappropriate content rating", 11475],
    ["Insufficient content warning", 11476]
  ]

  def email_and_send
    AdminMailer.abuse_report(id).deliver
    if email_copy?
      UserMailer.abuse_report(id).deliver
    end
    send_report
  end

  def send_report
    return unless %w(staging production).include?(Rails.env)
    reporter = AbuseReporter.new(
      title: url,
      description: comment,
      email: email,
      category: category,
      ip_address: ip_address
    )
    reporter.send_report!
  end

  # if the URL clearly belongs to a work (i.e. contains "/works/123")
  # make sure it isn't reported more than ABUSE_REPORTS_PER_WORK_MAX times per month
  def work_is_not_over_reported
    if url.match(/\/works\/\d+/)
      # use "/works/123/" to avoid matching chapter or external work ids
      work_params_only = url.match(/\/works\/\d+\//).to_s
      existing_reports_total = AbuseReport.where("created_at > ? AND
                                                 url LIKE ?",
                                                 1.month.ago,
                                                 "%#{work_params_only}%").
                                           count
      if existing_reports_total >= ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX
        errors[:base] << ts("URL has already been reported. To make sure the Abuse Team
                            can handle reports quickly and efficiently, we limit the
                            number of times a URL can be reported.")
      end
    end
  end
end
