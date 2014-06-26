require 'spec_helper'

describe AbuseReport do
  context "valid reports" do
    it "is valid" do
      build(:abuse_report).should be_valid
    end

    it "is valid without an email" do
      build(:abuse_report, email: nil).should be_valid
    end
  end

  context "comment missing" do
    let(:report_without_comment) {build(:abuse_report, comment: nil)}
    it "is invalid" do
      report_without_comment.save.should be_false
      report_without_comment.errors[:comment].should_not be_empty
    end
  end

  context "invalid emails" do

    BAD_EMAILS.each do |email|
      let(:bad_email) {build(:abuse_report, email: email)}
      it "cannot be created if the email does not pass veracity check" do
        bad_email.save.should be_false
        bad_email.errors[:email].should include("does not seem to be a valid address. Please use a different address or leave blank.")
      end
    end

  end

  context "invalid url" do
    let(:invalid_url){build(:abuse_report, url: "nothing before #{ArchiveConfig.APP_URL}")}
    it "text before url" do
      invalid_url.save.should be_false
      invalid_url.errors[:url].should_not be_empty
    end

    let(:not_from_site) {build(:abuse_report, url: "http://www.google.com/not/our/site")}
    it "url not from our site" do
      not_from_site.save.should be_false
      not_from_site.errors[:url].should_not be_empty
    end

    let(:no_url) {build(:abuse_report, url: "")}
    it "no url" do
      no_url.save.should be_false
      no_url.errors[:url].should_not be_empty
    end
  end

  context "email_copy?" do
    let(:no_email_provided) {build(:abuse_report, email: nil, cc_me: "1")}
    it "is invalid if an email is not provided" do
      no_email_provided.save.should be_false
      no_email_provided.errors[:email].should_not be_empty
    end

    let(:email_provided) {build(:abuse_report, cc_me: "1")}
    it "is valid if an email is provided" do
      email_provided.save.should be_true
      email_provided.errors[:email].should be_empty
    end
  end


end