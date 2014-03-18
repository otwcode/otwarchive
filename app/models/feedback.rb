# Class which holds feedback sent to the archive administrators about the archive as a whole
class Feedback < ActiveRecord::Base
  # note -- this has NOTHING to do with the Comment class!
  # This is just the name of the text field in the Feedback
  # class which holds the user's comments.
  validates_presence_of :comment
  validates_presence_of :summary
  validates :email, :email_veracity => {:allow_blank => true}
  validates_length_of :summary, :maximum => ArchiveConfig.FEEDBACK_SUMMARY_MAX_DISPLAYED,

    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.FEEDBACK_SUMMARY_MAX_DISPLAYED)

  validate :check_for_spam
  def check_for_spam
    errors.add(:base, ts("^This comment looks like spam to our system, sorry! Please try again, or create an account to comment.")) unless check_for_spam?
  end

  attr_protected :approved

  attr_protected :comment_sanitizer_version
  attr_protected :summary_sanitizer_version

  def akismet_attributes
    {
      :key => ArchiveConfig.AKISMET_KEY,
      :blog => ArchiveConfig.AKISMET_NAME,
      :user_ip => ip_address,
      :user_agent => user_agent,
      :comment_author_email => email,
      :comment_content => comment
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


# Category ids for 16bugs
 BUGS_ASSISTANCE = 11483
 BUGS_BUG = 11482
 BUGS_FEEDBACK = 11484
 BUGS_LANG = 11910
 BUGS_MISC = 11481
 BUGS_TAGS = 11485

# Category names, used on form
 BUGS_ASSISTANCE_NAME = 'Help Using the Archive'
 BUGS_BUG_NAME = 'Bug Report'
 BUGS_FEEDBACK_NAME = 'Feedback/Suggestions'
 BUGS_LANG_NAME = 'Languages/Translation'
 BUGS_MISC_NAME = 'General/Other'
 BUGS_TAGS_NAME = 'Tags'

end
