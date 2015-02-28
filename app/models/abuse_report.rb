class AbuseReport < ActiveRecord::Base
  validates_presence_of :comment
  validates_presence_of :url
  validates :email, :email_veracity => {:allow_blank => true}
  attr_accessor :cc_me
  validates :email, :presence => {:message => ts("cannot be blank if requesting an emailed copy of the Abuse Report")}, :if => "email_copy?"
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
end
