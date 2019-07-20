# frozen_string_literal: true

require 'spec_helper'

describe AdminMailer, type: :mailer do
  describe "send_spam_email" do
    let(:spam_user) { create(:user) }

    let(:spam1) do
      create(:posted_work, spam: true, title: "First Spam",
                           authors: [spam_user.default_pseud])
    end

    let(:spam2) do
      create(:posted_work, spam: true, title: "Second Spam",
                           authors: [spam_user.default_pseud])
    end

    let(:spam3) do
      create(:posted_work, spam: true, title: "Third Spam",
                           authors: [spam_user.default_pseud])
    end

    let(:other_user) { create(:user) }

    let(:other_spam) do
      create(:posted_work, spam: true, title: "Mistaken Spam",
                           authors: [other_user.default_pseud])
    end

    let!(:report) do
      {
        spam_user.id => { "score" => 13, "work_ids" => [spam1.id, spam2.id, spam3.id] },
        other_user.id => { "score" => 5, "work_ids" => [other_spam.id] }
      }
    end

    let(:mail) { AdminMailer.send_spam_alert(report) }

    context "when the report is valid" do
      it "has the correct subject" do
        expect(mail).to have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Potential spam alert"
      end

      it "delivers to the correct address" do
        expect(mail).to deliver_to ArchiveConfig.SPAM_ALERT_ADDRESS
      end

      it "delivers from the correct address" do
        expect(mail).to deliver_from("Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>")
      end

      it "lists the usernames and all work titles" do
        expect(mail.text_part).to have_body_text(/#{spam_user.login}/)
        expect(mail.text_part).to have_body_text(/#{spam1.title}/)
        expect(mail.text_part).to have_body_text(/#{spam2.title}/)
        expect(mail.text_part).to have_body_text(/#{spam3.title}/)

        expect(mail.text_part).to have_body_text(/#{other_user.login}/)
        expect(mail.text_part).to have_body_text(/#{other_spam.title}/)

        expect(mail.html_part).to have_body_text(/#{spam_user.login}/)
        expect(mail.html_part).to have_body_text(/#{spam1.title}/)
        expect(mail.html_part).to have_body_text(/#{spam2.title}/)
        expect(mail.html_part).to have_body_text(/#{spam3.title}/)

        expect(mail.html_part).to have_body_text(/#{other_user.login}/)
        expect(mail.html_part).to have_body_text(/#{other_spam.title}/)
      end

      it "lists the users in the correct order" do
        expect(mail.text_part).to have_body_text(/#{spam_user.login}.*#{other_user.login}/m)
        expect(mail.html_part).to have_body_text(/#{spam_user.login}.*#{other_user.login}/m)
      end
    end

    context "when a user has been deleted" do
      before { spam_user.destroy }

      context "when there are other users to list" do
        it "silently omits the missing user" do
          expect(mail.text_part).not_to have_body_text(/#{spam_user.login}/)
          expect(mail.text_part).not_to have_body_text(/#{spam1.title}/)
          expect(mail.text_part).not_to have_body_text(/#{spam2.title}/)
          expect(mail.text_part).not_to have_body_text(/#{spam3.title}/)

          expect(mail.text_part).to have_body_text(/#{other_user.login}/)
          expect(mail.text_part).to have_body_text(/#{other_spam.title}/)

          expect(mail.html_part).not_to have_body_text(/#{spam_user.login}/)
          expect(mail.html_part).not_to have_body_text(/#{spam1.title}/)
          expect(mail.html_part).not_to have_body_text(/#{spam2.title}/)
          expect(mail.html_part).not_to have_body_text(/#{spam3.title}/)

          expect(mail.html_part).to have_body_text(/#{other_user.login}/)
          expect(mail.html_part).to have_body_text(/#{other_spam.title}/)
        end
      end

      context "when there are no other users to list" do
        let!(:report) do
          {
            spam_user.id => { "score" => 13, "work_ids" => [spam1.id, spam2.id, spam3.id] }
          }
        end

        it "aborts delivery" do
          expect(mail.actual_message).to be_a(ActionMailer::Base::NullMail)
        end
      end
    end
  end
end
