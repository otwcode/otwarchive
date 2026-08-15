require "spec_helper"

describe TosUpdateMailer do
  describe "#tos_update_notification" do
    let(:user) { create(:user) }
    let(:admin_post) { create(:admin_post) }
    let(:email) { TosUpdateMailer.tos_update_notification(user, admin_post.id) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "a translated email"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Updates to #{ArchiveConfig.APP_SHORT_NAME}'s Terms of Service"
      expect(email).to have_subject(subject)
    end

    it "delivers to the correct address" do
      expect(email).to deliver_to(user.email)
    end

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("are or are not allowed. <b")
        expect(email).to have_html_part_content(">If your fanwork was allowed on AO3 before, then it is still allowed.</b>")
        expect(email).to have_html_part_content("href=\"#{admin_post_url(admin_post)}\"><b")
        expect(email).to have_html_part_content(">news post about the 2024 Terms of Service updates</b></a>")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("are or are not allowed. If your fanwork was allowed on AO3 before, then it is still allowed.")
        expect(email).to have_text_part_content("news post about the 2024 Terms of Service updates: #{admin_post_url(admin_post)}")
      end
    end
  end
end
