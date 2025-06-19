require "spec_helper"

describe TagWranglingSupervisorMailer do
  describe "#wrangler_username_change_notification" do
    let(:email) { TagWranglingSupervisorMailer.wrangler_username_change_notification(old_name, new_name) }
    let(:old_name) { "fast" }
    let(:new_name) { "express" }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "a translated email"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Wrangler name change"
      expect(email).to have_subject(subject)
    end

    it "delivers to the correct address" do
      expect(email).to deliver_to ArchiveConfig.TAG_WRANGLER_SUPERVISORS_ADDRESS
    end

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("The wrangler <b")
        expect(email).to have_html_part_content(">fast</b> has changed their name to <b")
        expect(email).to have_html_part_content(">express</b>.")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("The wrangler fast has changed their name to express.")
      end
    end
  end

  describe "#inactive_wrangler_notification" do
    let(:email) { TagWranglingSupervisorMailer.inactive_wrangler_notification([user1, user2]) }
    let(:user1) { "niki" }
    let(:user2) { "fed" }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "a translated email"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Wranglers who have not wrangled in 3 weeks"
      expect(email).to have_subject(subject)
    end

    it "delivers to the correct address" do
      expect(email).to deliver_to ArchiveConfig.TAG_WRANGLER_SUPERVISORS_ADDRESS
    end

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("The following wranglers have not been recorded as wrangling any tags in the past 3 weeks")
        expect(email).to have_html_part_content("<li>#{user1}</li>")
        expect(email).to have_html_part_content("<li>#{user2}</li>")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("The following wranglers have not been recorded as wrangling any tags in the past 3 weeks")
        expect(email).to have_text_part_content("  - #{user1}")
        expect(email).to have_text_part_content("  - #{user2}")
      end
    end
  end
end
