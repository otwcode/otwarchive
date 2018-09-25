# Class which holds feedback sent to the archive administrators about the archive as a whole
class Feedback < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  # note -- this has NOTHING to do with the Comment class!
  # This is just the name of the text field in the Feedback
  # class which holds the user's comments.
  validates_presence_of :comment
  validates_presence_of :summary
  validates_presence_of :language
  validates :email, email_veracity: { allow_blank: false }
  validates_length_of :summary, maximum: ArchiveConfig.FEEDBACK_SUMMARY_MAX,
    too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.FEEDBACK_SUMMARY_MAX_DISPLAYED)

  validate :check_for_spam
  def check_for_spam
    errors.add(:base, ts("^This comment looks like spam to our system, sorry! Please try again, or create an account to comment.")) unless check_for_spam?
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

  def check_for_spam?
    # don't check for spam while running tests
    self.approved = Rails.env.test? || !Akismetor.spam?(akismet_attributes)
  end

  def mark_as_spam!
    update_attribute(:approved, false)
    # don't submit spam reports unless in production mode
    Rails.env.production? && Akismetor.submit_spam(akismet_attributes)
  end

  def mark_as_ham!
    update_attribute(:approved, true)
    # don't submit ham reports unless in production mode
    Rails.env.production? && Akismetor.submit_ham(akismet_attributes)
  end

  def email_and_send
    AdminMailer.feedback(id).deliver
    UserMailer.feedback(id).deliver
    send_report
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
    return unless %w(staging production).include?(Rails.env)
    reporter = SupportReporter.new(
      title: summary,
      description: comment,
      language: language,
      email: email,
      username: username,
      user_agent: user_agent,
      site_revision: ArchiveConfig.REVISION.to_s,
      rollout: rollout
    )
    reporter.send_report!
  end
end
