require "spec_helper"

describe GiftExchangeMailer do
  describe "#no_potential_matches_notification" do
    subject(:email) { GiftExchangeMailer.no_potential_matches_notification(collection.id, "test@example.com") }

    let(:collection) { create(:collection) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] No potential matches found"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Potential match generation for <")
        expect(email).to have_html_part_content("your gift exchange's <")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Potential match generation for \"#{collection.title}\"")
        expect(email).to have_text_part_content("your gift exchange's Minimum Number to Match settings")
      end
    end
  end

  describe "#no_potential_matches_notification sent to collection_email" do
    subject(:email) { GiftExchangeMailer.no_potential_matches_notification(collection.id, collection.collection_email) }

    let(:collection) { create(:collection) }

    it_behaves_like "an email with a valid sender"

    describe "HTML version" do
      it "has the correct footer content" do
        expect(email).to have_html_part_content("your email address has been listed as the collection email")
      end
    end

    describe "text version" do
      it "has the correct footer content" do
        expect(email).to have_text_part_content("your email address has been listed as the collection email")
      end
    end
  end
end
