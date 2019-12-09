require "spec_helper"

describe UserMailer, type: :mailer do

  describe "claim_notification" do
    title = "Façade"
    title2 = Faker::Book.title
    let(:author) { create(:user) }
    let(:work) { create(:work, title: title, authors: [author.pseuds.first]) }
    let(:work2) { create(:work, title: title2, authors: [author.pseuds.first]) }

    subject(:email) { UserMailer.claim_notification(author.id, [work.id, work2.id], true).deliver }

    # Shared content tests for both email types
    shared_examples_for "a claim notification" do
      it "contains the text for a claim email" do
        expect(part).to include("You're receiving this e-mail because you had works in a fanworks archive that has been imported")
      end
    end

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Works uploaded"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    describe "HTML version" do
      it_behaves_like "a claim notification" do
        let(:part) { email.html_part.decoded }
      end

      it "lists the first imported work" do
        expect(email).to have_html_part_content(title)
      end

      it "lists the second imported work" do
        expect(email).to have_html_part_content(title2)
      end

      it "only has style_to links in the HTML body" do
        expect(email.html_part).not_to have_xpath("//a[not(@style)]")
      end
    end

    describe "text version" do
      it_behaves_like "a claim notification" do
        let(:part) { email.text_part.decoded }
      end

      it "lists the second imported work with a leading hyphen" do
        expect(email).to have_text_part_content("- #{title2}")
      end

      it "displays titles with non-ASCII characters" do
        expect(email).to have_text_part_content(title)
      end
    end
  end

  describe "invitation_to_claim" do
    title = Faker::Book.title
    title2 = Faker::Book.title

    let(:archivist) { create(:user) }
    let(:external_author) { create(:external_author) }

    let(:external_author_name) do
      create(:external_author_name,
             external_author_id: external_author.id,
             name: "External Author")
    end

    let(:invitation) do
      create(:invitation, external_author_id: external_author.id)
    end

    let(:work) { create(:work, title: title) }
    let(:work2) { create(:work, title: title2) }

    let!(:work_external_creatorship) do
      create(:external_creatorship,
             creation_id: work.id,
             external_author_name_id: external_author_name.id)
    end

    let!(:work2_external_creatorship) do
      create(:external_creatorship,
             creation_id: work2.id,
             external_author_name_id: external_author_name.id)
    end

    subject(:email) { UserMailer.invitation_to_claim(invitation.id, archivist.login).deliver }

    # Shared content tests for both email types
    shared_examples_for "an invitation to claim content" do
      it "contains the text for an invitation claim email" do
        expect(part).to include("You're receiving this e-mail because an archive has recently been imported by")
      end
    end

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation to claim works"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it_behaves_like "an invitation to claim content" do
        let(:part) { email.html_part.decoded }
      end

      it "lists the first imported work in an unordered list in the HTML body" do
        expect(email.html_part).to have_xpath("//ul/li", text: title)
      end

      it "lists the second imported work in an unordered list in the HTML body" do
        expect(email.html_part).to have_xpath("//ul/li", text: title2)
      end

      it "only has style_to links in the HTML body" do
        expect(email.html_part).not_to have_xpath("//a[not(@style)]")
      end
    end

    describe "text version" do
      it_behaves_like "an invitation to claim content" do
        let(:part) { email.text_part.decoded }
      end

      it "lists the first imported work as plain text" do
        expect(email.text_part).not_to have_xpath("//ul/li", text: title)
      end

      it "lists the second imported work with a leading hyphen" do
        expect(email).to have_text_part_content("- #{title2}")
      end
    end
  end
  
  describe "invitation" do
    context "when sent by a user" do
      let(:user) { create(:user) }
      let(:invitation) { create(:invitation, creator: user) }

      subject(:email) { UserMailer.invitation(invitation.id).deliver }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      it_behaves_like "a translated email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("like to join us, please sign up at the following address")
          expect(email).to have_html_part_content("has invited you")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("like to join us, please sign up at the following address")
          expect(email).to have_text_part_content("has invited you")
        end
      end
    end

    context "when sent from the queue or by an admin" do
      let(:invitation) { create(:invitation) }

      subject(:email) { UserMailer.invitation(invitation.id).deliver }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      it_behaves_like "a translated email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("like to join us, please sign up at the following address")
          expect(email).to have_html_part_content("been invited")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("like to join us, please sign up at the following address")
          expect(email).to have_text_part_content("been invited")
        end
      end
    end
  end

  describe "challenge_assignment_notification" do
    let!(:gift_exchange) { create(:gift_exchange) }
    let!(:collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let!(:otheruser) { create(:user) }
    let!(:offer) { create(:challenge_signup, collection: collection, pseud: otheruser.default_pseud) }
    let!(:open_assignment) { create(:challenge_assignment, collection: collection, offer_signup: offer) }

    subject(:email) { UserMailer.challenge_assignment_notification(collection.id, otheruser.id, open_assignment.id).deliver }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Your Assignment!"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("You have been assigned the following request")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("You have been assigned the following request")
      end
    end
  end

  describe "invite_request_declined" do
    let(:user) { create(:user) }
    let(:total) { 2 }
    let(:reason) { "You smell" }

    subject(:email) { UserMailer.invite_request_declined(user.id, total, reason).deliver }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Additional Invite Code Request Declined"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("We regret to inform you that your request for 2 new invitations cannot be fulfilled at this time")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("We regret to inform you that your request for 2 new invitations cannot be fulfilled at this time")
      end
    end
  end

  describe "invite_increase_notification" do
    let!(:user) { create(:user) }

    context "when 1 invitation is issued" do
      let!(:count) { 1 }
      subject(:email) { UserMailer.invite_increase_notification(user.id, count).deliver }

      # Test the headers
      it "has a valid sender" do
        expect(email.header["From"].to_s).to eq("Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>")
      end

      it "has the correct subject line" do
        expect(email.subject).to eq("[#{ArchiveConfig.APP_SHORT_NAME}] New Invitations")
      end

      # Test both body contents
      it_behaves_like "multipart email"

      describe "HTML version" do
        it "has expected text" do
          expect(get_message_part(email, /html/)).to include("you have #{count} new invitation")
        end
      
        it "does not have missing translations" do
          expect(get_message_part(email, /html/)).not_to include("translation missing")
        end
      
        it "does not have exposed HTML" do
          expect(get_message_part(email, /html/)).not_to include("&lt;")
        end
      end

      describe "text version" do
        it "has expected text" do
          expect(get_message_part(email, /plain/)).to include("you have #{count} new invitation")
        end
      
        it "does not have missing translations" do
          expect(get_message_part(email, /plain/)).not_to include("translation missing")
        end
      end
    end

    context "when multiple invitations are issued" do
      let!(:total) { 5 }
      subject(:email) { UserMailer.invite_increase_notification(user.id, total).deliver }

      # Test the headers
      it "has a valid sender" do
        expect(email.header["From"].to_s).to eq("Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>")
      end

      it "has the correct subject line" do
        expect(email.subject).to eq("[#{ArchiveConfig.APP_SHORT_NAME}] New Invitations")
      end

      # Test both body contents
      it_behaves_like "multipart email"

      describe "HTML version" do
         it "has expected text" do
          expect(get_message_part(email, /html/)).to include("you have #{total} new invitations")
        end
      
        it "does not have missing translations" do
          expect(get_message_part(email, /html/)).not_to include("translation missing")
        end
      
        it "does not have exposed HTML" do
          expect(get_message_part(email, /html/)).not_to include("&lt;")
        end
      end

      describe "text version" do
        it "has expected text" do
          expect(get_message_part(email, /plain/)).to include("you have #{total} new invitations")
        end
      
        it "does not have missing translations" do
          expect(get_message_part(email, /plain/)).not_to include("translation missing")
        end
      end
    end
  end
end
