require 'spec_helper'

describe AdminMailer, type: :mailer do

  describe "feedback" do
    let(:feedback) { create(:feedback) }
    let(:email) { AdminMailer.feedback(feedback.id) }

    it "has the correct subject" do
      expect(email).to have_subject("[#{ArchiveConfig.APP_SHORT_NAME}] Support - #{feedback.summary}")
    end

    it "delivers to the correct address" do
      expect(email).to deliver_to(ArchiveConfig.FEEDBACK_ADDRESS)
    end

    it "delivers from the correct address" do
      expect(email).to deliver_from(feedback.email)
    end

    it_behaves_like "a multipart email"

    describe "HTML email" do
      it "contains the comment" do
        expect(email).to have_html_part_content(feedback.comment)
      end

      it "contains the summary" do
        expect(email).to have_html_part_content(feedback.summary)
      end
    end

    describe "text email" do
      it "contains the comment" do
        expect(email).to have_text_part_content(feedback.comment)
      end

      it "contains the summary" do
        expect(email).to have_text_part_content(feedback.summary)
      end
    end
  end
end
