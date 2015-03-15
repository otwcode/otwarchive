class AbuseReport < ActiveRecord::Base
  validates_presence_of :comment
  validates_presence_of :url
  validates :email, :email_veracity => {:allow_blank => true}
  attr_accessor :cc_me
  validates :email, :presence => {:message => ts("cannot be blank if requesting an emailed copy of the Abuse Report")}, :if => "email_copy?"
  validate :work_is_not_over_reported

  scope :by_date, order("created_at DESC")

  attr_protected :comment_sanitizer_version

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

  # if the URL being reported belongs to a work
  # make sure it isn't reported more than ABUSE_REPORTS_PER_WORK_MAX times in a month
  def work_is_not_over_reported
    if url.match(/works\/\d+/)
      # use "works/123" instead of just the id to avoid confusion with chapter ids
      work_params_only = url.match(/works\/\d+/).to_s
      existing_reports_total = AbuseReport.where("created_at > ? AND
                                                 url LIKE ?",
                                                 1.month.ago,
                                                 "%#{work_params_only}%").
                                           count
      if existing_reports_total >= ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX + 1
        errors[:base] << ts("URL has already been reported. To make sure the Abuse Team
                            can handle reports quickly and efficiently, we limit the
                            number of times a URL can be reported.")
      end
    end
  end
end
