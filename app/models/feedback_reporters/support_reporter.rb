class SupportReporter < FeedbackReporter
  PROJECT_PATH = "authtoken=#{ArchiveConfig.SUPPORT_AUTH}&portal=#{ArchiveConfig.SUPPORT_PORTAL}&department=#{ArchiveConfig.SUPPORT_DEPARTMENT}"
  attr_accessor :user_agent, :site_revision, :rollout

  def template
    "feedbacks/report"
  end
end
