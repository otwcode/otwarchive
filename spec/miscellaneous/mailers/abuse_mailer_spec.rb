require 'spec_helper'
describe AdminMailer, type: :mailer do

  # Assume all of these reports pass the spam check
  before(:each) do
    allow(Akismetor).to receive(:spam?).and_return(false)
  end

  describe "abuse_report" do
    let(:report) { create(:abuse_report) }
    let(:email) { AdminMailer.abuse_report(report.id) }
    let(:email2) { UserMailer.abuse_report(report.id) }

    it "has the correct subject" do
      expect(email).to have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Abuse Report"
    end

    it "delivers to the correct address" do
      expect(email).to deliver_to ArchiveConfig.ABUSE_ADDRESS
    end

    it "ccs the user who filed the report" do
      expect(email2).to deliver_to(report.email)
    end

    it_behaves_like "an email with a valid sender"

    it_behaves_like "a multipart email"

    describe "HTML version" do
      it "contains the comment" do
        expect(email).to have_html_part_content(report.comment)
      end

      it "contains the email address" do
        expect(email).to have_html_part_content(report.email)
      end

      it "contains the url of the page with abuse" do
        expect(email).to have_html_part_content(report.url)
      end
    end

    describe "text version" do
      it "contains the comment" do
        expect(email).to have_text_part_content(report.comment)
      end

      it "contains the email address" do
        expect(email).to have_text_part_content(report.email)
      end

      it "contains the url of the page with abuse" do
        expect(email).to have_text_part_content(report.url)
      end
    end
  end
end
