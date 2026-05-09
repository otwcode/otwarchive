require "spec_helper"

describe GiftExchangeMailer do
  describe "#assignment_default_notification" do
    subject(:email) { UserMailer.assignment_default_notification(collection.id, challenge_assignment.id, "test@example.com") }

    let(:collection) { create(:collection) }
    let(:challenge_assignment) { create(:challenge_assignment) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Assignment default by #{challenge_assignment.offer_byline}"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("> has defaulted on their assignment for <")
        expect(email).to have_html_part_content("assign a pinch hitter on the <")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("has defaulted on their assignment for")
        expect(email).to have_text_part_content("assign a pinch hitter on the collection assignments page")
      end
    end
  end

  describe "#assignment_default_notification sent to collection_email" do
    subject(:email) { UserMailer.assignment_default_notification(collection.id, challenge_assignment.id, collection.collection_email) }

    let(:collection) { create(:collection) }
    let(:challenge_assignment) { create(:challenge_assignment) }

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

  describe "#assignments_sent_notification" do
    subject(:email) { UserMailer.assignments_sent_notification(collection.id, "test@example.com") }

    let(:collection) { create(:collection) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Assignments sent"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("sent out for your gift exchange <")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("sent out for your gift exchange \"#{collection.title}\"")
      end
    end
  end

  describe "#assignments_sent_notification sent to collection_email" do
    subject(:email) { UserMailer.assignments_sent_notification(collection.id, collection.collection_email) }

    let(:collection) { create(:collection) }
    let(:signup) { create(:challenge_signup) }

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

  describe "#invalid_signup_notification" do
    subject(:email) { UserMailer.invalid_signup_notification(collection.id, [signup.id], "test@example.com") }

    let(:collection) { create(:collection) }
    let(:signup) { create(:challenge_signup) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Invalid sign-ups found"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("invalid sign-ups in your gift exchange <")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("invalid sign-ups in your gift exchange \"#{collection.title}\"")
      end
    end
  end

  describe "#invalid_signup_notification sent to collection_email" do
    subject(:email) { UserMailer.invalid_signup_notification(collection.id, [signup.id], collection.collection_email) }

    let(:collection) { create(:collection) }
    let(:signup) { create(:challenge_signup) }

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

  describe "#potential_match_generation_notification" do
    subject(:email) { UserMailer.potential_match_generation_notification(collection.id, "test@example.com") }

    let(:collection) { create(:collection) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Potential assignment generation complete"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("potential assignments for your gift exchange <")
        expect(email).to have_html_part_content("on its <")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("potential assignments for your gift exchange \"#{collection.title}\"")
        expect(email).to have_text_part_content("on its Matching page:")
      end
    end
  end

  describe "#potential_match_generation_notification sent to collection_email" do
    subject(:email) { UserMailer.potential_match_generation_notification(collection.id, collection.collection_email) }

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
