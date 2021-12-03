require "spec_helper"

describe UserMailer do
  describe "claim_notification" do
    title = "Façade"
    title2 = Faker::Book.title

    subject(:email) { UserMailer.claim_notification(author.id, [work.id, work2.id], true) }

    let(:author) { create(:user) }
    let(:work) { create(:work, title: title, authors: [author.pseuds.first]) }
    let(:work2) { create(:work, title: title2, authors: [author.pseuds.first]) }

    # Shared content tests for both email types
    shared_examples_for "a claim notification" do
      it "contains the text for a claim email" do
        expect(part).to include("You're receiving this e-mail because you had works in a fanworks archive that has been imported")
        expect(part).to include("The Open Doors team")
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
        expect(email.html_part.decoded).not_to have_xpath("//a[not(@style)]")
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

    subject(:email) { UserMailer.invitation_to_claim(invitation.id, archivist.login) }

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

    # Shared content tests for both email types
    shared_examples_for "an invitation to claim content" do
      it "contains the text for an invitation claim email" do
        expect(part).to include("You're receiving this e-mail because an archive has recently been imported by")
        expect(part).to include("The Open Doors team")
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
        expect(email.html_part.decoded).to have_xpath("//ul/li", text: title)
      end

      it "lists the second imported work in an unordered list in the HTML body" do
        expect(email.html_part.decoded).to have_xpath("//ul/li", text: title2)
      end

      it "only has style_to links in the HTML body" do
        expect(email.html_part.decoded).not_to have_xpath("//a[not(@style)]")
      end
    end

    describe "text version" do
      it_behaves_like "an invitation to claim content" do
        let(:part) { email.text_part.decoded }
      end

      it "lists the first imported work as plain text" do
        expect(email.text_part.decoded).not_to have_xpath("//ul/li", text: title)
      end

      it "lists the second imported work with a leading hyphen" do
        expect(email).to have_text_part_content("- #{title2}")
      end
    end
  end

  describe "invitation" do
    context "when sent by a user" do
      subject(:email) { UserMailer.invitation(invitation.id) }

      let(:user) { create(:user) }
      let(:invitation) { create(:invitation, creator: user) }

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
      subject(:email) { UserMailer.invitation(invitation.id) }

      let(:invitation) { create(:invitation) }

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
    subject(:email) { UserMailer.challenge_assignment_notification(collection.id, otheruser.id, open_assignment.id) }

    let!(:gift_exchange) { create(:gift_exchange) }
    let!(:collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let!(:otheruser) { create(:user) }
    let!(:offer) { create(:challenge_signup, collection: collection, pseud: otheruser.default_pseud) }
    let!(:open_assignment) { create(:challenge_assignment, collection: collection, offer_signup: offer) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Your assignment!"
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
    subject(:email) { UserMailer.invite_request_declined(user.id, total, reason) }

    let(:user) { create(:user) }
    let(:total) { 2 }
    let(:reason) { "You smell" }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Additional invitation request declined"
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

  describe "signup_notification" do
    subject(:email) { UserMailer.signup_notification(user.id) }

    let(:user) { create(:user, :unconfirmed) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Confirmation"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Once your account is up and running, you can post your fanworks, set up email")
        expect(email).to have_html_part_content("follow this link to activate your account</a>.")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Once your account is up and running, you can post your fanworks, set up email")
        expect(email).to have_text_part_content("follow this link to activate your account:")
      end
    end
  end

  describe "invite_increase_notification" do
    let!(:user) { create(:user) }

    context "when 1 invitation is issued" do
      subject(:email) { UserMailer.invite_increase_notification(user.id, count) }

      let(:count) { 1 }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        expect(email.subject).to eq("[#{ArchiveConfig.APP_SHORT_NAME}] New invitations")
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      it_behaves_like "a translated email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("you have #{count} new invitation, which")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("you have #{count} new invitation, which")
        end
      end
    end

    context "when multiple invitations are issued" do
      subject(:email) { UserMailer.invite_increase_notification(user.id, count) }

      let(:count) { 5 }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        expect(email.subject).to eq("[#{ArchiveConfig.APP_SHORT_NAME}] New invitations")
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      it_behaves_like "a translated email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("you have #{count} new invitations, which")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("you have #{count} new invitations, which")
        end
      end
    end
  end

  describe "batch_subscription_notification" do
    subject(:email) { UserMailer.batch_subscription_notification(subscription.id, ["Work_#{work.id}", "Chapter_#{chapter.id}"].to_json) }

    let(:work) { create(:work, summary: "<p>Paragraph <u>one</u>.</p><p>Paragraph 2.</p>") }
    let(:chapter) { create(:chapter, work: work, posted: true, summary: "<p><b>Another</b> HTML summary.</p>") }
    let(:subscription) { create(:subscription, subscribable: work) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] #{subscription.subject_text(work)} and 1 more"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("new work")
        expect(email).to have_html_part_content("new chapter of")
      end

      it "includes HTML from the work summary" do
        expect(email).to have_html_part_content("<p>Paragraph <u>one</u>.</p>")
        expect(email).to have_html_part_content("<p>Paragraph 2.</p>")
      end

      it "includes HTML from the chapter summary" do
        expect(email).to have_html_part_content("<p><b>Another</b> HTML summary.</p>")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("new work")
        expect(email).to have_text_part_content("new chapter of #{work.title}")
      end

      it "reformats HTML from the work summary" do
        expect(email).to have_text_part_content("Paragraph _one_.")
        expect(email).to have_text_part_content("Paragraph 2.")
      end

      it "reformats HTML from the chapter summary" do
        expect(email).to have_text_part_content("*Another* HTML summary.")
      end
    end
  end

  describe "admin_hidden_work_notification" do
    subject(:email) { UserMailer.admin_hidden_work_notification(work.id, user.id) }

    let(:user) { create(:user) }
    let(:work) { create(:work, authors: [user.pseuds.first]) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Your work has been hidden by the Policy & Abuse team"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Dear <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
        expect(email).to have_html_part_content("> has been hidden")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Dear #{user.login},")
        expect(email).to have_text_part_content(") has been hidden")
      end
    end
  end

  describe "abuse_report" do
    let(:report) { create(:abuse_report) }
    let(:email) { UserMailer.abuse_report(report.id) }

    it "has the correct subject" do
      expect(email).to have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Your abuse report"
    end

    it "delivers to the user who filed the report" do
      expect(email).to deliver_to(report.email)
    end

    it_behaves_like "an email with a valid sender"

    it_behaves_like "a multipart email"

    describe "HTML version" do
      it "contains the comment and the URL reported" do
        expect(email).to have_html_part_content(report.comment)
        expect(email).to have_html_part_content(report.url)
      end
    end

    describe "text version" do
      it "contains the comment and the URL reported" do
        expect(email).to have_text_part_content(report.comment)
        expect(email).to have_text_part_content(report.url)
      end
    end
  end

  describe "feedback" do
    context "when username is present" do
      subject(:email) { UserMailer.feedback(feedback.id) }

      let(:feedback) { create(:feedback) }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Support - #{feedback.summary}"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("Hi!")
          expect(email).to have_html_part_content(">The AO3 Support team</b>")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("Hi!")
          expect(email).to have_text_part_content("The AO3 Support team")
        end
      end
    end

    context "when username is not present" do
      subject(:email) { UserMailer.feedback(feedback.id) }

      let(:feedback) { create(:feedback, username: "A. Name") }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Support - #{feedback.summary}"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("Hi, <b")
          expect(email).to have_html_part_content("#{feedback.username}</b>")
          expect(email).to have_html_part_content(">The AO3 Support team</b>")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("Hi, #{feedback.username}!")
          expect(email).to have_text_part_content("The AO3 Support team")
        end
      end
    end
  end

  describe "admin_spam_work_notification" do
    subject(:email) { UserMailer.admin_spam_work_notification(work.id, user.id) }

    let(:user) { create(:user) }
    let(:work) { create(:work, authors: [user.pseuds.first]) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Your work was hidden as spam"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Dear <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
        expect(email).to have_html_part_content("> has been flagged by our automated system")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Dear #{user.login},")
        expect(email).to have_text_part_content(") has been flagged by our automated system")
      end
    end
  end

  describe "invited_to_collection_notification" do
    subject(:email) { UserMailer.invited_to_collection_notification(user.id, work.id, collection.id) }

    let(:collection) { create(:collection) }
    let(:user) { create(:user) }
    let(:work) { create(:work, authors: [user.pseuds.first]) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Request to include work in a collection"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Dear <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Dear #{user.login},")
      end
    end
  end

  describe "added_to_collection_notification" do
    subject(:email) { UserMailer.added_to_collection_notification(user.id, work.id, collection.id) }

    let(:collection) { create(:collection) }
    let(:user) { create(:user) }
    let(:work) { create(:work, authors: [user.pseuds.first]) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Your work was added to a collection"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Dear <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Dear #{user.login},")
      end
    end
  end

  describe "recipient_notification" do
    context "when collection is present" do
      subject(:email) { UserMailer.recipient_notification(user.id, work.id, collection.id) }

      let(:user) { create(:user) }
      let(:work) { create(:work) }
      let(:collection) { create(:collection) }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] A gift work for you from #{collection.title}"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("Hi, <b")
          expect(email).to have_html_part_content("#{user.login}</b>")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("Hi, #{user.login}!")
        end
      end
    end

    context "when no collection is present" do
      subject(:email) { UserMailer.recipient_notification(user.id, work.id) }

      let(:user) { create(:user) }
      let(:work) { create(:work) }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] A gift work for you"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("Hi, <b")
          expect(email).to have_html_part_content("#{user.login}</b>")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("Hi, #{user.login}")
        end
      end
    end
  end

  describe "potential_match_generation_notification" do
    subject(:email) { UserMailer.potential_match_generation_notification(collection.id) }

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
        expect(email).to have_html_part_content("potential assignments for your challenge collection, <")
        expect(email).to have_html_part_content("challenge's <")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("potential assignments for your challenge collection \"#{collection.title}\"")
        expect(email).to have_text_part_content("challenge's Matching page:")
      end
    end
  end

  describe "invalid_signup_notification" do
    subject(:email) { UserMailer.invalid_signup_notification(collection.id, [signup.id]) }

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
        expect(email).to have_html_part_content("invalid sign-ups in your challenge <")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("invalid sign-ups in your challenge \"#{collection.title}\"")
      end
    end
  end

  describe "collection_notification" do
    subject(:email) { UserMailer.collection_notification(collection.id, subject_text, message_text) }

    let(:collection) { create(:collection) }
    let(:subject_text) { Faker::Hipster.sentence }
    let(:message_text) { Faker::Hipster.paragraph }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] #{subject_text}"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("your collection <")
        expect(email).to have_html_part_content("#{message_text}</blockquote>")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("your collection \"#{collection.title}\"")
        expect(email).to have_text_part_content(message_text)
      end
    end
  end

  describe "prompter_notification" do
    context "when collection is present" do
      subject(:email) { UserMailer.prompter_notification(work.id, collection.id) }

      let(:collection) { create(:collection) }
      let(:claim) { create(:challenge_claim, request_signup: create(:prompt_meme_signup)) }
      let(:work) { create(:work, challenge_claims: [claim]) }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] A response to your prompt"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("A response to your prompt")
          expect(email).to have_html_part_content("#{collection.title}</a>")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("A response to your prompt")
          expect(email).to have_text_part_content("\"#{collection.title}\" collection (#{collection_url(collection)})")
        end
      end
    end

    context "when no collection is present" do
      subject(:email) { UserMailer.prompter_notification(work.id) }

      let(:claim) { create(:challenge_claim, request_signup: create(:prompt_meme_signup)) }
      let(:work) { create(:work, challenge_claims: [claim]) }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] A response to your prompt"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("posted at the Archive")
          expect(email).not_to have_html_part_content("collection")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("posted at the Archive")
          expect(email).not_to have_text_part_content("collection")
        end
      end
    end
  end
end
