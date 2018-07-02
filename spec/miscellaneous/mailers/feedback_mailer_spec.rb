require 'spec_helper'

describe AdminMailer, type: :mailer do

  context "feedback with email" do
     let(:feedback) {create(:feedback)}
     let(:mail) {AdminMailer.feedback(feedback.id)}

     it "has the correct subject" do
       expect(mail).to have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Support - #{feedback.summary}"
     end

     it "delivers to the correct address" do
       expect(mail).to deliver_to ArchiveConfig.FEEDBACK_ADDRESS
     end

     it "delivers from the correct address" do
       expect(mail).to deliver_from feedback.email
     end

     it "body text contains the comment" do
       expect(mail).to have_body_text(/#{feedback.comment}/)
     end

     it "body text contains the summary" do
       expect(mail).to have_body_text(/#{feedback.summary}/)
     end

  end
end
