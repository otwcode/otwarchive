class AbuseReporter < FeedbackReporter
  PROJECT_PATH = "authtoken=#{ArchiveConfig.ABUSE_AUTH}&portal=#{ArchiveConfig.ABUSE_PORTAL}&department=#{ArchiveConfig.ABUSE_DEPARTMENT}"
  attr_accessor :ip_address

  def template
    "abuse_reports/report"
  end
end
