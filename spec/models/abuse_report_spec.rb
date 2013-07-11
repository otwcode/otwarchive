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
    it "is invalid" do
      build(:abuse_report, comment: nil).should be_invalid
    end
  end

  context "invalid emails" do
    it "email without @domain.com" do
      build(:abuse_report, email: "abcd").should be_invalid
    end

    it "email with bad suffix" do
      build(:abuse_report, email: "user@domain.badbadbad").should be_invalid
    end

  end

  context "invalid url" do
    it "text before url" do
      build(:abuse_report, url: "nothing before #{ArchiveConfig.APP_URL}").should be_invalid
    end

    it "url not from our site" do
      build(:abuse_report, url: "http://www.google.com/not/our/site").should be_invalid
    end

    it "no url" do
      build(:abuse_report, url: "").should be_invalid
    end
  end

  context "abuse_report cc_me" do
    it "is invalid if an email is not provided" do
      build(:abuse_report, email: nil, cc_me: true)
    end

    it "is valid if an email is provided" do
      build(:abuse_report, cc_me: true)
    end
  end

end