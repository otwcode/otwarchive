# A mailer for new comments on the fake blog
class BlogCommentMailer < ActionMailer::Base
  # Send email about new comments
  def comment_notification
    @subject = t('subject')
  end
end

# Set the path to where the mail template will be found
BlogCommentMailer.template_root = "#{File.dirname(__FILE__)}/../views"
