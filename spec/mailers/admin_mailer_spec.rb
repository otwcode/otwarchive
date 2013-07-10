require 'spec_helper'
describe AdminMailer do
  context "#abuse_reports" do
    let(:report) {create(:abuse_report)}
    let(:mail) {AdminMailer.abuse_report(report.id)}

    it "has the correct subject" do
      mail.subject.should == "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Abuse Report"
    end
  end
end