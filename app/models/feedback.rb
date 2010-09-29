# Class which holds feedback sent to the archive administrators about the archive as a whole
class Feedback < ActiveRecord::Base
  # note -- this has NOTHING to do with the Comment class!
  # This is just the name of the text field in the Feedback
  # class which holds the user's comments. 
  validates_presence_of :comment
  validates_presence_of :summary
  validates_email_veracity_of :email, :allow_blank => true, 
    :message => t('invalid_email', :default => 'address appears to be invalid. Please use a different address or leave blank.') 
  validates_length_of :summary, :maximum => ArchiveConfig.FEEDBACK_SUMMARY_MAX,
    :too_long => t('summary_too_long', :default => "must be less than %{max} characters long.", :max => ArchiveConfig.FEEDBACK_SUMMARY_MAX)


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
