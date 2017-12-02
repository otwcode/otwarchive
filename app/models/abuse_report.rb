class AbuseReport < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  validates :email, email_veracity: { allow_blank: false }
  validates_presence_of :language
  validates_presence_of :summary
  validates_presence_of :comment
  validates_presence_of :url
  validate :url_is_not_over_reported
  validates_length_of :summary, maximum: ArchiveConfig.FEEDBACK_SUMMARY_MAX,
                                too_long: ts('must be less than %{max}
                                             characters long.',
                                max: ArchiveConfig.FEEDBACK_SUMMARY_MAX_DISPLAYED)

  scope :by_date, -> { order('created_at DESC') }

  # Clean work or profile URLs so we can prevent the same URLs from
  # getting reported too many times.
  # If the URL ends without a / at the end, add it:
  # url_is_not_over_reported uses the / so "/works/1234" isn't a match
  # for "/works/123"
  before_validation :clean_url, on: :create
  def clean_url
    # Work URLs: "works/123"
    # Profile URLs: "users/username"
    if url =~ /(works\/\d+)/ || url =~ /(users\/\w+)/
      uri = Addressable::URI.parse url
      uri.query = nil
      uri.fragment = nil
      uri.path += "/" unless uri.path.end_with? "/"
      self.url = uri.to_s
    else
      url
    end
  end

  app_url_regex = Regexp.new('^https?:\/\/(www\.|insecure\.)?' +
                             ArchiveConfig.APP_HOST, true)
  validates_format_of :url, with: app_url_regex,
                            message: ts('does not appear to be on this site.'),
                            multiline: true

  def email_and_send
    AdminMailer.abuse_report(id).deliver
    UserMailer.abuse_report(id).deliver
    send_report
  end

  def send_report
    return unless %w(staging production).include?(Rails.env)
    reporter = AbuseReporter.new(
      title: summary,
      description: comment,
      language: language,
      email: email,
      username: username,
      ip_address: ip_address,
      url: url
    )
    reporter.send_report!
  end

  # if the URL clearly belongs to a work (i.e. contains "/works/123")
  # or a user profile (i.e. contains "/users/username")
  # make sure it isn't reported more than ABUSE_REPORTS_PER_WORK_MAX
  # or ABUSE_REPORTS_PER_USER_MAX times per month
  def url_is_not_over_reported
    message = ts('URL has already been reported. To make sure the Abuse Team
                 can handle reports quickly and efficiently, we limit the number
                 of times a URL can be reported.')
    if url =~ /\/works\/\d+/
      # use "/works/123/" to avoid matching chapter or external work ids
      work_params_only = url.match(/\/works\/\d+\//).to_s
      existing_reports_total = AbuseReport.where('created_at > ? AND
                                                 url LIKE ?',
                                                 1.month.ago,
                                                 "%#{work_params_only}%").count
      if existing_reports_total >= ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX
        errors[:base] << message
      end
    elsif url =~ /\/users\/\w+/
      user_params_only = url.match(/\/users\/\w+\//).to_s
      existing_reports_total = AbuseReport.where('created_at > ? AND
                                                 url LIKE ?',
                                                 1.month.ago,
                                                 "%#{user_params_only}%").count
      if existing_reports_total >= ArchiveConfig.ABUSE_REPORTS_PER_USER_MAX
        errors[:base] << message
      end
    end
  end
end
