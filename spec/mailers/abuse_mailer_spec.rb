require 'spec_helper'
describe AdminMailer do
  context "abuse_reports with email" do
    let(:report) {create(:abuse_report)}
    let(:mail) {AdminMailer.abuse_report(report.id)}

    it "has the correct subject" do
      mail.should have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Abuse Report"
    end

    it "delivers to the correct address" do
      mail.should deliver_to ArchiveConfig.ABUSE_ADDRESS
    end

    it "delivers from the correct address" do
      mail.should deliver_from ArchiveConfig.RETURN_ADDRESS
    end

    it "body text contains the comment" do
      mail.should have_body_text(/#{report.comment}/)
    end

    it "body text contains the email" do
      mail.should have_body_text(/#{report.email}/)
    end

    it "has the url of the page with abuse" do
      mail.should have_body_text(/#{report.url}/)
    end

  end

  context "abuse_reports without email" do
    let(:report) {create(:abuse_report)}
    let(:mail) {AdminMailer.abuse_report(report.id)}

    it "has the correct subject" do
      mail.should have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Abuse Report"
    end

    it "delivers to the correct address" do
      mail.should deliver_to ArchiveConfig.ABUSE_ADDRESS
    end

    it "delivers from the correct address" do
      mail.should deliver_from ArchiveConfig.RETURN_ADDRESS
    end

    it "body text contains the comment" do
      mail.should have_body_text(/#{report.comment}/)
    end

    it "has the url of the page with abuse" do
      mail.should have_body_text(/#{report.url}/)
    end

  end

  context "abuse_reports sends copy if cc_me is checked" do
   pending
  end


end