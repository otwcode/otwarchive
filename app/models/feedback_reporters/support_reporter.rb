class SupportReporter < FeedbackReporter

  attr_accessor :user_agent, :site_revision

  def template
    "feedbacks/report"
  end
end
