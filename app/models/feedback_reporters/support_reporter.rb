class SupportReporter < FeedbackReporter
  PROJECT_PATH = "authtoken=#{ArchiveConfig.SUPPORT_AUTH}&portal=ao3support&department=Support"
  attr_accessor :user_agent, :site_revision, :rollout

  def template
    "feedbacks/report"
  end
end
