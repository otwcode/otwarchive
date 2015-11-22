class AbuseReporter < FeedbackReporter
  PROJECT_ID = 4603

  attr_accessor :ip_address

  def template
    "abuse_reports/report"
  end
end
