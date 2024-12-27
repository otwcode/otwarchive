class AbuseReport < ApplicationRecord
  attr_accessor :locale_language
  
  validates :email, email_format: { allow_blank: false }
  validates :locale_language, presence: true
  validates :summary, presence: true
  validates :comment, presence: true
  validates :url, presence: true
  validate :url_is_not_over_reported
  validate :email_is_not_over_reporting
  validates :summary, length: { maximum: ArchiveConfig.FEEDBACK_SUMMARY_MAX,
                                too_long: t("abuse_report.too_long", max: ArchiveConfig.FEEDBACK_SUMMARY_MAX_DISPLAYED) }

  # It doesn't have the type set properly in the database, so override it here:
  attribute :summary_sanitizer_version, :integer, default: 0

  validate :check_for_spam
  def check_for_spam
    approved = logged_in_with_matching_email? || !Akismetor.spam?(akismet_attributes)
    errors.add(:base, t("abuse_report.spam")) unless approved
  end

  def logged_in_with_matching_email?
    User.current_user.present? && User.current_user.email == email
  end

  def akismet_attributes
    name = username || ""
    {
      comment_type: "contact-form",
      key: ArchiveConfig.AKISMET_KEY,
      blog: ArchiveConfig.AKISMET_NAME,
      user_ip: ip_address,
      comment_author: name,
      comment_author_email: email,
      comment_content: comment
    }
  end

  scope :by_date, -> { order("created_at DESC") }

  # Standardize the format of work, chapter, and profile URLs to get it ready
  # for the url_is_not_over_reported validation.
  # Work URLs: "works/123"
  # Chapter URLs: "chapters/123"
  # Profile URLs: "users/username"
  before_validation :standardize_url, on: :create
  def standardize_url
    return unless url =~ %r{((chapters|works)/\d+)} || url =~ %r{(users/\w+)}

    self.url = add_scheme_to_url(url)
    self.url = clean_url(url)
    self.url = add_work_id_to_url(self.url)
  end

  def add_scheme_to_url(url)
    uri = Addressable::URI.parse(url)
    return url unless uri.scheme.nil?

    "https://#{uri}"
  end

  # Clean work or profile URLs so we can prevent the same URLs from getting
  # reported too many times.
  # If the URL ends without a / at the end, add it: url_is_not_over_reported
  # uses the / so "/works/1234" isn't a match for "/works/123"
  def clean_url(url)
    uri = Addressable::URI.parse(url)

    uri.query = nil
    uri.fragment = nil
    uri.path += "/" unless uri.path.end_with? "/"

    uri.to_s
  end

  # Get the chapter id from the URL and try to get the work id
  # If successful, add the work id to the URL in front of "/chapters"
  def add_work_id_to_url(url)
    return url unless url =~ %r{(chapters/\d+)} && url !~ %r{(works/\d+)}

    chapter_regex = %r{(chapters/)(\d+)}
    regex_groups = chapter_regex.match url
    chapter_id = regex_groups[2]
    work_id = Chapter.find_by(id: chapter_id).try(:work_id)

    return url if work_id.nil?

    uri = Addressable::URI.parse(url)
    uri.path = "/works/#{work_id}" + uri.path

    uri.to_s
  end

  validate :url_on_archive, if: :will_save_change_to_url?
  def url_on_archive
    parsed_url = Addressable::URI.heuristic_parse(url)
    errors.add(:url, :not_on_archive) unless ArchiveConfig.PERMITTED_HOSTS.include?(parsed_url.host)
  rescue Addressable::URI::InvalidURIError
    errors.add(:url, :not_on_archive)
  end

  def email_and_send
    UserMailer.abuse_report(id).deliver_later
    send_report
  end

  def send_report
    return unless %w[staging production].include?(Rails.env)

    reporter = AbuseReporter.new(
      title: summary,
      description: comment,
      locale_language: locale_language,
      email: email,
      username: username,
      ip_address: ip_address,
      url: url
    )
    response = reporter.send_report!
    ticket_id = response["id"]
    return if ticket_id.blank?

    attach_work_download(ticket_id)
  end

  def attach_work_download(ticket_id)
    is_not_comments = url[%r{/comments/}, 0].nil?
    work_id = url[%r{/works/(\d+)}, 1]
    return unless work_id && is_not_comments

    work = Work.find_by(id: work_id)
    ReportAttachmentJob.perform_later(ticket_id, work) if work
  end

  # if the URL clearly belongs to a work (i.e. contains "/works/123")
  # or a user profile (i.e. contains "/users/username")
  # make sure it isn't reported more than ABUSE_REPORTS_PER_WORK_MAX
  # or ABUSE_REPORTS_PER_USER_MAX times per month
  def url_is_not_over_reported
    message = t("abuse_report.already_reported")
    case url
    when %r{/works/\d+}
      # use "/works/123/" to avoid matching chapter or external work ids
      work_params_only = url.match(%r{/works/\d+/}).to_s
      existing_reports_total = AbuseReport.where('created_at > ? AND
                                                 url LIKE ?',
                                                 1.month.ago,
                                                 "%#{work_params_only}%").count
      errors.add(:base, message) if existing_reports_total >= ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX
    when %r{/users/\w+}
      user_params_only = url.match(%r{/users/\w+/}).to_s
      existing_reports_total = AbuseReport.where('created_at > ? AND
                                                 url LIKE ?',
                                                 1.month.ago,
                                                 "%#{user_params_only}%").count
      errors.add(:base, message) if existing_reports_total >= ArchiveConfig.ABUSE_REPORTS_PER_USER_MAX
    end
  end

  def email_is_not_over_reporting
    existing_reports_total = AbuseReport.where("created_at > ? AND
                                               email LIKE ?",
                                               1.day.ago,
                                               email).count
    return if existing_reports_total < ArchiveConfig.ABUSE_REPORTS_PER_EMAIL_MAX

    errors.add(:base, t("abuse_report.daily_limit_reached"))
  end
end
