require 'spec_helper'

describe Feedback do
  context "when report is not spam" do
    context "valid reports" do
      it "is valid" do
        expect(build(:feedback)).to be_valid
      end
    end

    context "comment missing" do
      let(:report_without_comment) { build(:feedback, comment: nil) }
      it "is invalid" do
        expect(report_without_comment.save).to be_falsey
        expect(report_without_comment.errors[:comment]).not_to be_empty
      end
    end

    context "comment with weird characters" do
      it "is valid with slash and dot" do
        expect(build(:feedback, comment: "/.")).to be_valid
      end
      it "is valid in other languages" do
        expect(build(:feedback, comment: "café")).to be_valid
      end
      it "is valid in other alphabets" do
        expect(build(:feedback, comment: "γεια")).to be_valid
      end
    end

    context "provided email is invalid" do
      BAD_EMAILS.each do |email|
        let(:bad_email) { build(:feedback, email: email) }
        it "fails email format check and cannot be created" do
          expect(bad_email.save).to be_falsey
          expect(bad_email.errors[:email]).to include("should look like an email address.")
        end
      end
    end

    context "with IP address" do
      let(:ip) { Faker::Internet.ip_v4_address }
      let(:feedback) { create(:feedback, ip_address: ip) }
  
      it "has IP in Akismet attributes" do
        expect(feedback.akismet_attributes[:user_ip]).to eq(ip)
      end
  
      it "does not store IP in the database" do
        expect(Feedback.find(feedback.id)[:ip_address]).to be_nil
      end
    end

    let(:no_email_provided) { build(:feedback, email: nil) }
    it "is invalid if an email is not provided" do
      expect(no_email_provided.save).to be_falsey
      expect(no_email_provided.errors[:email]).not_to be_empty
    end

    let(:email_provided) { build(:feedback) }
    it "is valid if an email is provided" do
      expect(email_provided.save).to be_truthy
      expect(email_provided.errors[:email]).to be_empty
    end
  end

  context "when report is spam" do
    let(:legit_user) { create(:user) }
    let(:spam_report) { build(:feedback, username: 'viagra-test-123') }
    let(:safe_report) { build(:feedback, username: 'viagra-test-123', email: legit_user.email) }

    before do
      allow(Akismetor).to receive(:spam?).and_return(true)
    end

    it "is not valid if Akismet flags it as spam" do
      expect(spam_report.save).to be_falsey
      expect(spam_report.errors[:base]).to include("This report looks like spam to our system!")
    end

    it "is valid even with spam if logged in and providing correct email" do
      User.current_user = legit_user
      expect(safe_report.save).to be_truthy
    end
  end

  describe "#email_and_send" do
    shared_examples "uses the default locale" do
      it "localizes the email with the default locale" do
        expect(I18n).to receive(:with_locale).with(Locale.default.iso)
        feedback.email_and_send
      end
    end

    context "when the set locale preference feature flag is on" do
      before do
        $rollout.activate(:set_locale_preference)
      end

      context "and the feedback uses an existing language whose locale supports emails" do
        let(:language) { create(:language) }
        let(:locale) { create(:locale, language: language, email_enabled: true) }
        let!(:feedback) { create(:feedback, language: language.name) }

        it "localizes the email with the feedback's language locale" do
          expect(I18n).to receive(:with_locale).with(locale.iso)
          feedback.email_and_send
        end
      end

      context "and the feedback uses an existing language whose locale does not support emails" do
        let(:language) { create(:language) }
        let(:locale) { create(:locale, language: language, email_enabled: false) }
        let!(:feedback) { create(:feedback, language: language.name) }

        it_behaves_like "uses the default locale"
      end

      context "and the feedback uses an unknown language" do
        let!(:feedback) { create(:feedback, language: "-1") }

        it_behaves_like "uses the default locale"
      end
    end

    context "when the set locale preference feature flag is off" do
      let(:language) { create(:language) }
      let(:locale) { create(:locale, language: language, email_enabled: true) }
      let!(:feedback) { create(:feedback, language: language.name) }

      before do
        $rollout.deactivate(:set_locale_preference)
      end

      it_behaves_like "uses the default locale"
    end
  end
end
