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
end
