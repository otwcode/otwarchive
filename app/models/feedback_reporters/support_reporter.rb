class SupportReporter < FeedbackReporter
  PROJECT_ID = 4911

  attr_accessor :user_agent, :site_revision

  def template
    "feedbacks/report"
  end
end
