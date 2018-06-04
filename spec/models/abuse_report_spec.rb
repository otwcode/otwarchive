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

  shared_examples "enough already" do |url|
    let(:report) { build(:abuse_report, url: url) }
    it "can't be submitted" do
      expect(report.save).to be_falsey
      expect(report.errors[:base].first).to include("URL has already been reported.")
    end
  end

  shared_examples "alright" do |url|
    let(:report) { build(:abuse_report, url: url) }
    it "can be submitted" do
      expect(report.save).to be_truthy
      expect(report.errors[:base]).to be_empty
    end
  end

  context "for a work reported the maximum number of times" do
    work_url = "http://archiveofourown.org/works/789"

    before do
      ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX.times do
        create(:abuse_report, url: work_url)
      end
      expect(AbuseReport.count).to eq(ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX)
    end

    # obviously
    it_behaves_like "enough already", work_url

    # the same work, different protocol
    it_behaves_like "enough already", "https://archiveofourown.org/works/789"

    # the same work, with parameters/anchors
    it_behaves_like "enough already", "http://archiveofourown.org/works/789?smut=yes"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789?smut=yes#timeline"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789#timeline"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/?smut=yes"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/#timeline"

    # the same work, in a collection
    it_behaves_like "enough already", "http://archiveofourown.org/collections/rarepair/works/789"

    # the same work, under users
    it_behaves_like "enough already", "http://archiveofourown.org/users/author/works/789"
    it_behaves_like "enough already", "http://archiveofourown.org/users/coauthor/works/789"

    # the same work, subpages
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/bookmarks"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/collections"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/comments"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/kudos"

    # a specific chapter on the work
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/chapters/123"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/chapters/123#major-character-death"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/chapters/123?ending=1"
    it_behaves_like "enough already", "http://archiveofourown.org/works/789/chapters/123?ending=2#major-character-death"

    # the same work: variations we don't cover
    it_behaves_like "alright", "http://archiveofourown.org/chapters/123"
    it_behaves_like "alright", "http://archiveofourown.org/comments/show_comments?work_id=789"

    # not the same work
    it_behaves_like "alright", "http://archiveofourown.org/works/9009"
    it_behaves_like "alright", "http://archiveofourown.org/works/78"
    it_behaves_like "alright", "http://archiveofourown.org/works/7890"
    it_behaves_like "alright", "http://archiveofourown.org/external_works/789"

    # unrelated
    it_behaves_like "alright", "http://archiveofourown.org/users/someone"

    context "a month later" do
      before { Timecop.freeze(32.days.from_now) }
      after { Timecop.return }

      it_behaves_like "alright", work_url
    end
  end

  context "for a user profile reported the maximum number of times" do
    user_url = "http://archiveofourown.org/users/someone"

    before do
      ArchiveConfig.ABUSE_REPORTS_PER_USER_MAX.times do
        create(:abuse_report, url: user_url)
      end
      expect(AbuseReport.count).to eq(ArchiveConfig.ABUSE_REPORTS_PER_USER_MAX)
    end

    # obviously
    it_behaves_like "enough already", user_url

    # the same user, different protocol
    it_behaves_like "enough already", "https://archiveofourown.org/users/someone"

    # the same user, with parameters/anchors
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone?sfw=yes"
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone?sfw=yes#timeline"
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone#timeline"
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone/?sfw=yes"
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone/#timeline"

    # the same user, as admin (why admin?)
    it_behaves_like "enough already", "http://archiveofourown.org/admin/users/someone"

    # the same user, subpages
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone/bookmarks"
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone/claims"
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone/pseuds/"
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone/pseuds/ghostwriter"
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone/pseuds/g h o s t w r i t e r"

    # the same user, Unicode in parameters
    it_behaves_like "enough already", "http://archiveofourown.org/users/someone/inbox?utf8=✓&filters[read]=false"

    # not the same user
    it_behaves_like "alright", "http://archiveofourown.org/users/some"
    it_behaves_like "alright", "http://archiveofourown.org/users/someoneelse"
    it_behaves_like "alright", "http://archiveofourown.org/users/somebody"

    # unrelated
    it_behaves_like "alright", "http://archiveofourown.org/works/789"

    context "a month later" do
      before { Timecop.freeze(32.days.from_now) }
      after { Timecop.return }

      it_behaves_like "alright", user_url
    end
  end

  context "for a URL that is not a work" do
    page_url = "http://archiveofourown.org/tags/Testing/works"

    let(:common_report) { build(:abuse_report, url: page_url) }
    it "can be submitted an unrestricted number of times" do
      ArchiveConfig.ABUSE_REPORTS_PER_WORK_MAX.times do
        create(:abuse_report, url: page_url)
      end
      expect(common_report.save).to be_truthy
      expect(common_report.errors[:base]).to be_empty
    end
  end
end
