# Class which holds feedback sent to the archive administrators about the archive as a whole
class Feedback < ApplicationRecord
  attr_accessor :ip_address, :referer, :site_skin, :locale_language

  # NOTE: this has NOTHING to do with the Comment class!
  # This is just the name of the text field in the Feedback
  # class which holds the user's comments.
  validates :comment, presence: true
  validates :summary, presence: true
  validates :locale_language, presence: true
  validates :email, email_format: { allow_blank: false }
  validates :summary, length: { maximum: ArchiveConfig.FEEDBACK_SUMMARY_MAX,
                                too_long: I18n.t("feedbacks.too_long", max: ArchiveConfig.FEEDBACK_SUMMARY_MAX_DISPLAYED) }

  validate :check_for_spam
  def check_for_spam
    approved = logged_in_with_matching_email? || !Akismetor.spam?(akismet_attributes)
    errors.add(:base, I18n.t("feedbacks.spam")) unless approved
  end

  def logged_in_with_matching_email?
    User.current_user.present? && User.current_user.email == email
  end

  def akismet_attributes
    {
      key: ArchiveConfig.AKISMET_KEY,
      blog: ArchiveConfig.AKISMET_NAME,
      user_ip: ip_address,
      user_agent: user_agent,
      comment_author_email: email,
      comment_content: comment
    }
  end

  def mark_as_spam!
    # don't submit spam reports unless in production mode
    Rails.env.production? && Akismetor.submit_spam(akismet_attributes)
  end

  def mark_as_ham!
    # don't submit ham reports unless in production mode
    Rails.env.production? && Akismetor.submit_ham(akismet_attributes)
  end

  def email_and_send
    UserMailer.feedback(id).deliver_later
    send_report
  end

  def rollout_string
    ""
    # ES UPGRADE TRANSITION #
    # Remove ES version logic, but leave this method for future rollout use
    # string << if Feedback.use_new_search?
    #             "ES 6.0"
    #           else
    #             "ES 0.90"
    #           end
  end

  def send_report
    return unless zoho_enabled?

    reporter = SupportReporter.new(
      title: summary,
      description: comment,
      locale_language: locale_language,
      email: email,
      username: username,
      user_agent: user_agent,
      site_revision: ArchiveConfig.REVISION.to_s,
      rollout: rollout,
      ip_address: ip_address,
      referer: referer,
      site_skin: site_skin
    )
    reporter.send_report!
  end

  private

  def zoho_enabled?
    %w[staging production].include?(Rails.env)
  end
end
