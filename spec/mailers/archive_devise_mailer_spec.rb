require "spec_helper"

describe ArchiveDeviseMailer do
  describe "reset_password_instructions" do
    subject(:email) { ArchiveDeviseMailer.reset_password_instructions(user, token) }

    context "when user is User" do
      let(:user) { create(:user) }
      let(:token) { user.reset_password_token }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reset your password"
        expect(email.subject).to eq(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      it_behaves_like "a translated email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("Hi <")
          expect(email).to have_html_part_content("use this link to choose a new password")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("Hi #{user.login},")
          expect(email).to have_text_part_content("use this link to choose a new password")
        end
      end
    end

    context "when user is Admin" do
      let(:user) { create(:admin) }
      let(:token) { user.reset_password_token }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reset your admin password"
        expect(email.subject).to eq(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      it_behaves_like "a translated email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("Hi <")
          expect(email).to have_html_part_content("Change my password.")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("Hi #{user.login},")
          expect(email).not_to have_text_part_content("Change my password.")
        end
      end
    end
  end

  describe "#confirmation_instructions" do
    let(:user) { create(:user, confirmation_sent_at: Time.new(2020, 4, 10, 10, 51, 0, "+00:00")) }
    subject(:email) { ArchiveDeviseMailer.confirmation_instructions(user, token: "fakeToken") }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Confirm your email change"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Hi,")
        expect(email).to have_html_part_content(">confirm your email change</a> within #{ArchiveConfig.DAYS_UNTIL_RESET_PASSWORD_LINK_EXPIRES} days")
        expect(email).to have_html_part_content("If you don't confirm your request by")
        expect(email).to have_html_part_content(", #{ArchiveConfig.DAYS_UNTIL_RESET_PASSWORD_LINK_EXPIRES + 10} Apr 2020 10:51:00 +0000, the link in")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Hi,")
        expect(email).to have_text_part_content("confirm your email change within #{ArchiveConfig.DAYS_UNTIL_RESET_PASSWORD_LINK_EXPIRES} days")
        expect(email).to have_html_part_content("If you don't confirm your request by")
        expect(email).to have_html_part_content(", #{ArchiveConfig.DAYS_UNTIL_RESET_PASSWORD_LINK_EXPIRES + 10} Apr 2020 10:51:00 +0000, the link in")
      end
    end
  end

  describe "#password_change" do
    subject(:email) { ArchiveDeviseMailer.password_change(record) }

    context "when the record is a user" do
      let(:record) { create(:user) }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Your password has been changed"
        expect(email.subject).to eq(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      it_behaves_like "a translated email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("Hi <b")
          expect(email).to have_html_part_content("#{record.login}</b>,")
          expect(email).to have_html_part_content("The password for your AO3 account was changed")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("Hi #{record.login},")
          expect(email).to have_text_part_content("The password for your AO3 account was changed")
        end
      end
    end

    context "when the record is an admin" do
      let(:record) { create(:admin) }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Your admin password has been changed"
        expect(email.subject).to eq(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      it_behaves_like "a translated email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("Hi <b")
          expect(email).to have_html_part_content("#{record.login}</b>,")
          expect(email).to have_html_part_content("The password for your AO3 admin account was changed")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("Hi #{record.login},")
          expect(email).to have_text_part_content("The password for your AO3 admin account was changed")
        end
      end
    end
  end
end
