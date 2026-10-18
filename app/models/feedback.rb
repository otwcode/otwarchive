# Class which holds feedback sent to the archive administrators about the archive as a whole
class Feedback
  include ActiveModel::Model

  attr_accessor :summary, :comment, :language,
                :email, :username, :user_agent, :ip_address,
                :referer, :site_skin, :rollout

  # NOTE: this has NOTHING to do with the Comment class!
  # This is just the name of the text field in the Feedback
  # class which holds the user's comments.
  validates_presence_of :comment
  validates_presence_of :summary
  validates_presence_of :language
  validates :email, email_format: { allow_blank: false }
  # i18n-tasks-use t("activemodel.errors.models.feedback.attributes.summary.too_long")
  validates :summary, length: { maximum: ArchiveConfig.FEEDBACK_SUMMARY_MAX,
                                too_long: :too_long, max_displayed: ArchiveConfig.FEEDBACK_SUMMARY_MAX_DISPLAYED }

  validate :check_for_spam, unless: :logged_in_with_matching_email?
  def check_for_spam
    # i18n-tasks-use t("activemodel.errors.models.feedback.attributes.base.spam")
    errors.add(:base, :spam) if AkismetClient.spam?(akismet_attributes)
  end

  def logged_in_with_matching_email?
    User.current_user.present? && User.current_user.email == email
  end

  def akismet_attributes
    # If the user is logged in and we're sending info to Akismet, we can assume
    # the email does not match.
    role = User.current_user.present? ? "user-with-nonmatching-email" : "guest"
    {
      comment_type: "contact-form",
      user_ip: ip_address,
      user_agent: user_agent,
      user_role: role,
      comment_author_email: email,
      comment_content: comment
    }
  end

  def mailer_attributes
    {
      email: email,
      summary: summary,
      comment: comment,
      username: username,
      language: language
    }
  end

  def email_and_send
    if self.send_report
      UserMailer.feedback(self.mailer_attributes).deliver_later
      return true
    end
    false
  end

  def rollout_string
    string = ""
    # ES UPGRADE TRANSITION #
    # Remove ES version logic, but leave this method for future rollout use
    # string << if Feedback.use_new_search?
    #             "ES 6.0"
    #           else
    #             "ES 0.90"
    #           end
  end

  def send_report
    return true unless zoho_enabled?

    reporter = SupportReporter.new(
      title: summary,
      description: comment,
      language: language,
      email: email,
      username: username,
      user_agent: user_agent,
      site_revision: ArchiveConfig.REVISION.to_s,
      rollout: rollout,
      ip_address: ip_address,
      referer: referer,
      site_skin: site_skin
    )
    reporter.send_report!&.dig("id").present?
  end

  private

  def zoho_enabled?
    %w[staging production].include?(Rails.env)
  end
end
