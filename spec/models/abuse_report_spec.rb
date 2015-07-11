require 'spec_helper'

describe AbuseReport do
  context "valid reports" do
    it "is valid" do
      expect(build(:abuse_report)).to be_valid
    end

    it "is valid without an email" do
      expect(build(:abuse_report, email: nil)).to be_valid
    end
  end

  context "comment missing" do
    let(:report_without_comment) {build(:abuse_report, comment: nil)}
    it "is invalid" do
      expect(report_without_comment.save).to be_falsey
      expect(report_without_comment.errors[:comment]).not_to be_empty
    end
  end

  context "invalid emails" do

    BAD_EMAILS.each do |email|
      let(:bad_email) {build(:abuse_report, email: email)}
      it "cannot be created if the email does not pass veracity check" do
        expect(bad_email.save).to be_falsey
        expect(bad_email.errors[:email]).to include("does not seem to be a valid address. Please use a different address or leave blank.")
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

  context "email_copy?" do
    let(:no_email_provided) {build(:abuse_report, email: nil, cc_me: "1")}
    it "is invalid if an email is not provided" do
      expect(no_email_provided.save).to be_falsey
      expect(no_email_provided.errors[:email]).not_to be_empty
    end

    let(:email_provided) {build(:abuse_report, cc_me: "1")}
    it "is valid if an email is provided" do
      expect(email_provided.save).to be_truthy
      expect(email_provided.errors[:email]).to be_empty
    end
  end


end