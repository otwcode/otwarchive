require 'spec_helper'

describe AdminMailer do

  context "feedback with email" do
     let(:feedback) {create(:feedback)}
     let(:mail) {AdminMailer.feedback(feedback.id)}

     it "has the correct subject" do
       mail.should have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Support - #{feedback.summary}"
     end

     it "delivers to the correct address" do
       mail.should deliver_to ArchiveConfig.FEEDBACK_ADDRESS
     end

     it "delivers from the correct address" do
       mail.should deliver_from feedback.email
     end

     it "body text contains the comment" do
       mail.should have_body_text(/#{feedback.comment}/)
     end

     it "body text contains the summary" do
       mail.should have_body_text(/#{feedback.summary}/)
     end

  end


  context 'feedback without email' do
    let(:feedback) {create(:feedback, email: nil)}
    let(:mail) {AdminMailer.feedback(feedback.id)}

    it "has the correct subject" do
      mail.should have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Support - #{feedback.summary}"
    end

    it "delivers to the correct address" do
      mail.should deliver_to ArchiveConfig.FEEDBACK_ADDRESS
    end

    it "delivers from the correct address" do
      mail.should deliver_from ArchiveConfig.RETURN_ADDRESS
    end

    it "body text contains the comment" do
      mail.should have_body_text(/#{feedback.comment}/)
    end

    it "body text contains the summary" do
      mail.should have_body_text(/#{feedback.summary}/)
    end
  end
end