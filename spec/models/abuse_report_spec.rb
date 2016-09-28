require 'spec_helper'

describe AbuseReport do
  context "valid reports" do
    it "is valid" do
      expect(build(:abuse_report)).to be_valid
    end
  end

  context "comment missing" do
    let(:report_without_comment) {build(:abuse_report, comment: nil)}
    it "is invalid" do
      expect(report_without_comment.save).to be_falsey
      expect(report_without_comment.errors[:comment]).not_to be_empty
    end
  end

  context "comment with weird characters" do
    it "is valid with slash and dot" do
      expect(build(:abuse_report, comment: "/.")).to be_valid
    end
    it "is valid in other languages" do
      expect(build(:abuse_report, comment: "café")).to be_valid
    end
    it "is valid in other alphabets" do
      expect(build(:abuse_report, comment: "γεια")).to be_valid
    end
  end

  context "invalid emails" do

    BAD_EMAILS.each do |email|
      let(:bad_email) {build(:abuse_report, email: email)}
      it "cannot be created if the email does not pass veracity check" do
        expect(bad_email.save).to be_falsey
        expect(bad_email.errors[:email]).to include("does not seem to be a valid address.")
      end
    end

  end

  context "invalid url" do
    let(:invalid_url){build(:abuse_report, url: "nothing before #{ArchiveConfig.APP_URL}")}
    it "text before url" do
      expect(invalid_url.save).to be_falsey
      expect(invalid_url.errors[:url]).not_to be_empty
    end

    let(:not_from_site) {build(:abuse_report, url: "http://www.google.com/not/our/site")}
    it "url not from our site" do
      expect(not_from_site.save).to be_falsey
      expect(not_from_site.errors[:url]).not_to be_empty
    end

    let(:no_url) {build(:abuse_report, url: "")}
    it "no url" do
      expect(no_url.save).to be_falsey
      expect(no_url.errors[:url]).not_to be_empty
    end
  end

  context "emailed copy" do
    let(:no_email_provided) { build(:abuse_report, email: nil) }
    it "is invalid if an email is not provided" do
      expect(no_email_provided.save).to be_falsey
      expect(no_email_provided.errors[:email]).not_to be_empty
    end

    let(:email_provided) { build(:abuse_report) }
    it "is valid if an email is provided" do
      expect(email_provided.save).to be_truthy
      expect(email_provided.errors[:email]).to be_empty
    end
  end

  context "for an already-reported work" do
    work_url = "http://archiveofourown.org/works/1234"

    let(:common_report) { build(:abuse_report, url: work_url) }
    it "can be submitted up to a set number of times" do
      (ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX - 1).times do
        create(:abuse_report, url: work_url)
      end
      expect(common_report.save).to be_truthy
      expect(common_report.errors[:base]).to be_empty
    end
  end

  context "for a work reported the maximum number of times" do
    work_url = "http://archiveofourown.org/works/789"
    work_url_variant = "http://archiveofourown.org/works/789/chapters/123"

    let(:common_report) { build(:abuse_report, url: work_url) }
    it "can't be submitted" do
      ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX.times do
        create(:abuse_report, url: work_url)
      end
      expect(common_report.save).to be_falsey
      expect(common_report.errors[:base]).not_to be_empty
    end

    let(:common_report_variant) { build(:abuse_report, url: work_url_variant) }
    it "can't be submitted with a variation of the URL" do
      ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX.times do
        create(:abuse_report, url: work_url)
      end
      expect(common_report_variant.save).to be_falsey
      expect(common_report_variant.errors[:base]).not_to be_empty
    end
  end
end