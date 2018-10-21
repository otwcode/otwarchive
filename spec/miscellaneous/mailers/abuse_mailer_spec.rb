require 'spec_helper'
describe AdminMailer, type: :mailer do
  context "abuse_reports with email" do
    let(:report) { create(:abuse_report) }
    let(:mail) { AdminMailer.abuse_report(report.id) }

    it "has the correct subject" do
      expect(mail).to have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Abuse Report"
    end

    it "delivers to the correct address" do
      expect(mail).to deliver_to ArchiveConfig.ABUSE_ADDRESS
    end

    it "delivers from the correct address" do
      expect(mail).to deliver_from("Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>")
    end

    it "body text contains the comment" do
      expect(mail).to have_body_text(/#{report.comment}/)
    end

    it "body text contains the email" do
      expect(mail).to have_body_text(/#{report.email}/)
    end

    it "has the url of the page with abuse" do
      expect(mail.html_part).to have_body_text(report.url)
    end

  end

  context "abuse_reports sends copy to submitter" do
    let(:report) { create(:abuse_report, email: "cc_me@email.com") }
    let(:mail) { AdminMailer.abuse_report(report.id) }
    let(:mail2) { UserMailer.abuse_report(report.id) }


   it "has the correct subject" do
     expect(mail).to have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Abuse Report"
   end

   it "delivers to the correct address" do
     expect(mail).to deliver_to ArchiveConfig.ABUSE_ADDRESS
   end

   it "ccs the user who filed the report" do
     expect(mail2).to deliver_to("cc_me@email.com")
   end

   it "delivers from the correct address" do
     expect(mail).to deliver_from("Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>")
   end

   it "body text contains the comment" do
     expect(mail).to have_body_text(/#{report.comment}/)
   end

   it "has the url of the page with abuse" do
     expect(mail.html_part).to have_body_text(report.url)
   end
  end


end
