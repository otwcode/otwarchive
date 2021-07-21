# frozen_string_literal: true

require 'spec_helper'

describe AdminMailer do
  describe "send_spam_alert" do
    let(:spam_user) { create(:user) }

    let(:spam1) do
      create(:work, spam: true, title: "First Spam",
                           authors: [spam_user.default_pseud])
    end

    let(:spam2) do
      create(:work, spam: true, title: "Second Spam",
                           authors: [spam_user.default_pseud])
    end

    let(:spam3) do
      create(:work, spam: true, title: "Third Spam",
                           authors: [spam_user.default_pseud])
    end

    let(:other_user) { create(:user) }

    let(:other_spam) do
      create(:work, spam: true, title: "Mistaken Spam",
                           authors: [other_user.default_pseud])
    end

    let!(:report) do
      {
        spam_user.id => { "score" => 13, "work_ids" => [spam1.id, spam2.id, spam3.id] },
        other_user.id => { "score" => 5, "work_ids" => [other_spam.id] }
      }
    end

    let(:email) { AdminMailer.send_spam_alert(report) }

    context "when the report is valid" do
      it "has the correct subject" do
        expect(email).to have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Potential spam alert"
      end

      it "delivers to the correct address" do
        expect(email).to deliver_to ArchiveConfig.SPAM_ALERT_ADDRESS
      end

      it_behaves_like "an email with a valid sender"

      it_behaves_like "a multipart email"

      describe "HTML version" do
        it "lists the usernames and all work titles" do
          expect(email).to have_html_part_content(spam_user.login)
          expect(email).to have_html_part_content(spam1.title)
          expect(email).to have_html_part_content(spam2.title)
          expect(email).to have_html_part_content(spam3.title)

          expect(email).to have_html_part_content(other_user.login)
          expect(email).to have_html_part_content(other_spam.title)
        end

        it "lists the users in the correct order" do
          expect(email.html_part.decoded).to have_text(/#{spam_user.login}.*#{other_user.login}/m)
        end
      end

      describe "text version" do
        it "lists the usernames and all work titles" do
          expect(email).to have_text_part_content(spam_user.login)
          expect(email).to have_text_part_content(spam1.title)
          expect(email).to have_text_part_content(spam2.title)
          expect(email).to have_text_part_content(spam3.title)

          expect(email).to have_text_part_content(other_user.login)
          expect(email).to have_text_part_content(other_spam.title)
        end

        it "lists the users in the correct order" do
          expect(email.text_part.decoded).to have_text(/#{spam_user.login}.*#{other_user.login}/m)
        end
      end
    end

    context "when a user has been deleted" do
      before do
        # Users can't delete their account without doing something with their
        # works first. Here we're orphaning the works:
        create(:user, login: "orphan_account")
        Creatorship.orphan(spam_user.pseuds, spam_user.works, true)
        spam_user.destroy
      end

      context "when there are other users to list" do
        describe "HTML version" do
          it "silently omits the missing user" do
            expect(email).not_to have_html_part_content(spam_user.login)
            expect(email).not_to have_html_part_content(spam1.title)
            expect(email).not_to have_html_part_content(spam2.title)
            expect(email).not_to have_html_part_content(spam3.title)

            expect(email).to have_html_part_content(other_user.login)
            expect(email).to have_html_part_content(other_spam.title)
          end
        end

        describe "text version" do
          it "silently omits the missing user" do
            expect(email).not_to have_text_part_content(spam_user.login)
            expect(email).not_to have_text_part_content(spam1.title)
            expect(email).not_to have_text_part_content(spam2.title)
            expect(email).not_to have_text_part_content(spam3.title)

            expect(email).to have_text_part_content(other_user.login)
            expect(email).to have_text_part_content(other_spam.title)
          end
        end
      end

      context "when there are no other users to list" do
        let!(:report) do
          {
            spam_user.id => { "score" => 13, "work_ids" => [spam1.id, spam2.id, spam3.id] }
          }
        end

        it "aborts delivery" do
          expect(email.message).to be_a(ActionMailer::Base::NullMail)
        end
      end
    end
  end

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
