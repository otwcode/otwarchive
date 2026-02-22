require "spec_helper"

describe UserMailer do
  include ActionView::Helpers::UrlHelper
  include MailerHelper

  describe "#change_email" do
    let(:login) { "changer" }
    let(:new_email) { "new@example.com" }
    let(:user) { create(:user, login: login) }
    subject(:email) { UserMailer.change_email(user.id, "old@example.com", new_email) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Email change request"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Hi <b")
        expect(email).to have_html_part_content(">#{login}</b>,")
        expect(email).to have_html_part_content("If you made this request, check your email at <a")
        expect(email).to have_html_part_content("#{new_email}</a> within #{ArchiveConfig.DAYS_UNTIL_RESET_PASSWORD_LINK_EXPIRES} days to confirm your email change")

        expect(email).to have_html_part_content("don't understand why you received this email, please <a")
        expect(email).to have_html_part_content(">contact Policy & Abuse</a>.")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Hi #{login},")
        expect(email).to have_text_part_content("If you made this request, check your email at #{new_email} within #{ArchiveConfig.DAYS_UNTIL_RESET_PASSWORD_LINK_EXPIRES} days to confirm your email change")

        expect(email).to have_text_part_content("If you don't understand why you received this email, please contact Policy & Abuse")
      end
    end
  end

  describe "#change_username" do
    let(:old_username) { "olduser" }
    let(:new_username) { "newuser" }
    let(:user) { create(:user, login: new_username, renamed_at: Time.zone.parse("2025-01-01 00:00:00")) }
    subject(:email) { UserMailer.change_username(user, old_username) }

    before do
      allow(ArchiveConfig).to receive(:USER_RENAME_LIMIT_DAYS).and_return(5)
    end

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Your username has been changed"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Hi,")
        expect(email).to have_html_part_content(">#{old_username}</b> has been changed to <b style=\"color:#990000\">#{new_username}</b>")

        expect(email).to have_html_part_content("can only be changed once every 5 days")
        expect(email).to have_html_part_content("You will be able to change your username again on Mon, 06 Jan 2025 00:00:00 +0000")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Hi,")
        expect(email).to have_text_part_content("#{old_username} has been changed to #{new_username}")

        expect(email).to have_text_part_content("can only be changed once every 5 days")
        expect(email).to have_text_part_content("You will be able to change your username again on Mon, 06 Jan 2025 00:00:00 +0000")
      end
    end
  end

  describe "creatorship_request" do
    include ActiveJob::TestHelper
    def queue_adapter_for_test
      ActiveJob::QueueAdapters::TestAdapter.new
    end

    subject(:email) { UserMailer.creatorship_request(work_creatorship.id, author.id) }

    let(:author) { create(:user) }
    let(:second_author) { create(:user) }
    let(:work) { create(:work, authors: [author.default_pseud, second_author.default_pseud]) }
    let(:work_creatorship) { Creatorship.find_by(creation_id: work.id, pseud_id: second_author.default_pseud.id) }

    context "when the creation is unavailable" do
      before { work_creatorship.creation.delete }

      include_examples "it retries and fails on", ActionView::Template::Error
    end

    context "when the pseud being invited is unavailable" do
      before { work_creatorship.pseud.delete }

      include_examples "it retries and fails on", NoMethodError
    end

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] You've received a request to be a co-creator"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("to be listed as a co-creator")
        expect(email).to have_html_part_content(" page.")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("to be listed as a co-creator")
        expect(email).to have_text_part_content("You can accept or reject this request on your Co-Creator Requests page:")
      end
    end
  end

  describe "#creatorship_notification" do
    include ActiveJob::TestHelper
    def queue_adapter_for_test
      ActiveJob::QueueAdapters::TestAdapter.new
    end

    subject(:email) { UserMailer.creatorship_notification(chapter_creatorship.id, author.id) }

    let(:author) { create(:user) }
    let(:second_author) { create(:user) }
    let(:chapter) { create(:chapter, authors: [author.default_pseud, second_author.default_pseud]) }
    let(:chapter_creatorship) { chapter.creatorships.last }

    context "when the creation is unavailable" do
      before { chapter_creatorship.creation.delete }

      include_examples "it retries and fails on", ActionView::Template::Error
    end

    context "when the pseud being invited is unavailable" do
      before { chapter_creatorship.pseud.delete }

      include_examples "it retries and fails on", NoMethodError
    end

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] You've been added as a co-creator"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("to be listed as a creator")
        expect(email).to have_html_part_content("remove yourself as creator.")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("to be listed as a creator")
        expect(email).to have_text_part_content("remove yourself as creator:")
      end
    end
  end

  describe "creatorship_notification_archivist" do
    include ActiveJob::TestHelper
    def queue_adapter_for_test
      ActiveJob::QueueAdapters::TestAdapter.new
    end

    subject(:email) { UserMailer.creatorship_notification_archivist(work_creatorship.id, author.id) }

    let(:author) { create(:user) }
    let(:second_author) { create(:user) }
    let(:work) { create(:work, authors: [author.default_pseud, second_author.default_pseud]) }
    let(:work_creatorship) { Creatorship.find_by(creation_id: work.id, pseud_id: second_author.default_pseud.id) }

    context "when the creation is unavailable" do
      before { work_creatorship.creation.delete }

      include_examples "it retries and fails on", ActionView::Template::Error
    end

    context "when the pseud being invited is unavailable" do
      before { work_creatorship.pseud.delete }

      include_examples "it retries and fails on", NoMethodError
    end

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] An archivist has added you as a co-creator"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("to be listed as a creator")
        expect(email).to have_html_part_content("remove yourself as creator.")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("to be listed as a creator")
        expect(email).to have_text_part_content("remove yourself as creator:")
      end
    end
  end

  describe "claim_notification" do
    title = "Façade"
    title2 = Faker::Book.title

    subject(:email) { UserMailer.claim_notification(author.id, [work.id, work2.id]) }

    let(:author) { create(:user) }
    let(:work) { create(:work, title: title, authors: [author.pseuds.first]) }
    let(:work2) { create(:work, title: title2, authors: [author.pseuds.first]) }

    # Shared content tests for both email types
    shared_examples_for "a claim notification" do
      it "contains the text for a claim email" do
        expect(part).to include("You're receiving this email because you had works in a fanworks archive that has been imported")
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

    it_behaves_like "a translated email"

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
        expect(email).to have_text_part_content("- \"#{title2}\"")
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
        expect(part).to include("You're receiving this email because an archive has recently been imported by")
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
        expect(email).to have_text_part_content("- \"#{title2}\"")
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
          expect(email).to have_html_part_content("follow this link to sign up</a>")
          expect(email).to have_html_part_content("has invited you")
          expect(email).to have_html_part_content("Organization for Transformative Works</a>, which works to protect fan rights and preserve fanworks.")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("like to join us, please follow this link to sign up")
          expect(email).to have_text_part_content("has invited you")
          expect(email).to have_text_part_content("the Organization for Transformative Works (https://www.transformativeworks.org), which works to protect fan rights and preserve fanworks")
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
          expect(email).to have_html_part_content("follow this link to sign up")
          expect(email).to have_html_part_content("been invited")
          expect(email).to have_html_part_content("Organization for Transformative Works</a>, which works to protect fan rights and preserve fanworks.")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("like to join us, please follow this link to sign up")
          expect(email).to have_text_part_content("been invited")
          expect(email).to have_text_part_content("the Organization for Transformative Works (https://www.transformativeworks.org), which works to protect fan rights and preserve fanworks")
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
    let!(:open_assignment) { create(:challenge_assignment, collection: collection, offer_signup: offer, sent_at: Time.current) }

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
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Activate your account"
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
          expect(email).to have_html_part_content("your invitations page</a>.")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("you have #{count} new invitation, which")
          expect(email).to have_text_part_content("your invitations page (")
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
          expect(email).to have_html_part_content("your invitations page</a>.")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("you have #{count} new invitations, which")
          expect(email).to have_text_part_content("your invitations page (")
        end
      end
    end
  end

  describe "batch_subscription_notification" do
    include ActiveJob::TestHelper
    def queue_adapter_for_test
      ActiveJob::QueueAdapters::TestAdapter.new
    end

    subject(:email) { UserMailer.batch_subscription_notification(subscription.id, entries) }

    let(:creator) { create(:pseud) }
    let(:work) { create(:work, summary: "<p>Paragraph <u>one</u>.</p><p>Paragraph 2.</p>", authors: [creator], character_string: "A,B") }
    let(:chapter) { create(:chapter, work: work, summary: "<p><b>Another</b> HTML summary.</p>", authors: [creator]) }
    let(:series) { create(:series, works: [work]) }
    let(:subscription) { create(:subscription, subscribable: creator.user) }
    let(:entries) { ["Work_#{work.id}", "Chapter_#{chapter.id}"].to_json }

    context "when the user is unavailable" do
      before { subscription.user.delete }

      include_examples "it retries and fails on", NoMethodError
    end

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] #{creator.byline} posted #{work.title} and 1 more"
      expect(email).to have_subject(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        work_link = "<i><b>#{style_link(work.title, work_url(work))}</b></i>"
        expect(email).to have_html_part_content("#{creator_links(work)} posted a new work:")
        expect(email).to have_html_part_content("#{creator_links(work)} posted a new chapter of #{work_link} (#{work.word_count} words):")
      end

      it "includes HTML from the work summary" do
        expect(email).to have_html_part_content("<p>Paragraph <u>one</u>.</p>")
        expect(email).to have_html_part_content("<p>Paragraph 2.</p>")
      end

      it "includes the series link" do
        label = "<b style=\"color:#990000\">Series: </b>"
        link = "Part 1 of <a style=\"color:#990000\" href=\"#{series_url(series)}\">#{series.title}</a>"
        expect(email).to have_html_part_content("#{label}#{link}")
      end

      it "includes HTML from the chapter summary" do
        expect(email).to have_html_part_content("<p><b>Another</b> HTML summary.</p>")
      end

      # AO3-5804 Only show chapter byline if it differs from work byline
      it "has the correct chapter link without attribution" do
        chapter_link = "<i><b>#{style_link(chapter.full_chapter_title.html_safe, work_chapter_url(work, chapter))}</b></i>"
        expect(email).to have_html_part_content("#{chapter_link} (#{chapter.word_count} words)")
        expect(email).not_to have_html_part_content("#{chapter_link} (#{chapter.word_count} words)<br />by")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("#{creator_text(work)} posted a new work:")
        expect(email).to have_text_part_content("#{creator_text(work)} posted a new chapter of \"#{work.title}\"")
      end

      it "reformats HTML from the work summary" do
        expect(email).to have_text_part_content("Paragraph _one_.")
        expect(email).to have_text_part_content("Paragraph 2.")
      end

      it "includes the series list" do
        expect(email).to have_text_part_content("Series: Part 1 of #{series.title}")
      end

      it "reformats HTML from the chapter summary" do
        expect(email).to have_text_part_content("*Another* HTML summary.")
      end

      # AO3-5804 Only show chapter byline if it differs from work byline
      it "has the correct chapter link without attribution" do
        expect(email).to have_text_part_content("\"#{chapter.full_chapter_title.html_safe}\" (#{chapter.word_count} words)")
        expect(email).not_to have_text_part_content("\"#{chapter.full_chapter_title.html_safe}\" (#{chapter.word_count} words)\nby")
      end
    end

    context "when the creation is a chapter" do
      let(:entries) { ["Chapter_#{chapter.id}"].to_json }

      context "with different creators than the work" do
        let(:creator1) { create(:user).default_pseud }
        let(:creator2) { create(:user).default_pseud }
        let(:work) { create(:work, authors: [creator1, creator2]) }
        let(:chapter) { create(:chapter, work: work, authors: [creator1]) }

        it "has the correct subject line" do
          subject = "[#{ArchiveConfig.APP_SHORT_NAME}] #{creator1.byline} posted #{chapter.chapter_header} of #{work.title}"
          expect(email).to have_subject(subject)
        end

        it "has the correct preface in the HTML version" do
          work_link = "<i><b>#{style_link(work.title, work_url(work))}</b></i>"
          expect(email).to have_html_part_content("#{style_pseud_link(creator1)} and #{style_pseud_link(creator2)} posted a new chapter of #{work_link} (#{work.word_count} words):")
        end

        it "has the correct preface in the text version" do
          expect(email).to have_text_part_content("#{text_pseud(creator1)} and #{text_pseud(creator2)} posted a new chapter of \"#{work.title}\" (#{work.word_count} words):\n#{work_chapter_url(work, chapter)}")
        end

        # AO3-5805 Show chapter byline on chapter, not work byline
        it "has the correct chapter link with chapter attribution in the HTML version" do
          chapter_link = "<i><b>#{style_link(chapter.full_chapter_title.html_safe, work_chapter_url(work, chapter))}</b></i>"
          expect(email).to have_html_part_content("#{chapter_link} (#{chapter.word_count} words)<br />by #{style_pseud_link(creator1)}")
          expect(email).not_to have_html_part_content("#{chapter_link} (#{chapter.word_count} words)<br />by #{style_pseud_link(creator1)} and #{style_pseud_link(creator2)}")
        end

        # AO3-5805 Show chapter byline on chapter, not work byline
        it "has the correct chapter title with chapter attribution in the text version" do
          expect(email).to have_text_part_content("\"#{chapter.full_chapter_title.html_safe}\" (#{chapter.word_count} words)\nby #{text_pseud(creator1)}")
          expect(email).not_to have_text_part_content("\"#{chapter.full_chapter_title.html_safe}\" (#{chapter.word_count} words)\nby #{text_pseud(creator1)} and #{text_pseud(creator2)}")
        end
      end
    end

    context "when using translations" do
      before do
        create(:locale, iso: "new")
        I18n.backend.store_translations(:new, { support: { array: { words_connector: "|" } }, activerecord: { models: { character: { other: "People" } } } })
      end

      it "results in different work info per locale" do
        I18n.with_locale(I18n.default_locale) do
          en_email = UserMailer.batch_subscription_notification(subscription.id, entries)
          expect(en_email).to have_html_part_content("Characters: </b>A, B")
          expect(en_email).to have_text_part_content("Characters: A, B")
        end

        I18n.with_locale(:new) do
          translated_email = UserMailer.batch_subscription_notification(subscription.id, entries)
          expect(translated_email).to have_html_part_content("People: </b>A|B")
          expect(translated_email).to have_text_part_content("People: A|B")
        end
      end
    end
  end

  describe "admin_hidden_work_notification" do
    subject(:email) { UserMailer.admin_hidden_work_notification([work.id], user.id) }

    let(:user) { create(:user) }
    let(:work) { create(:work, authors: [user.pseuds.first]) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Your work has been hidden by the Policy & Abuse committee"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Hi <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
        expect(email).to have_html_part_content("> has been hidden")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Hi #{user.login},")
        expect(email).to have_text_part_content(") has been hidden")
      end
    end
  end

  describe "abuse_report" do
    let(:report) { create(:abuse_report) }
    let(:email) { UserMailer.abuse_report(report.id) }

    it "has the correct subject" do
      expect(email).to have_subject "[#{ArchiveConfig.APP_SHORT_NAME}] Abuse - #{report.summary}"
    end

    it "delivers to the user who filed the report" do
      expect(email).to deliver_to(report.email)
    end

    it_behaves_like "an email with a valid sender"

    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

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

    describe "translation" do
      it "formats the date rightfully in English" do
        travel_to "2022-03-14 13:27:09 +0000" do
          expect(email).to have_html_part_content("Sent at Mon, 14 Mar 2022 13:27:09 +0000.")
          expect(email).to have_text_part_content("Sent at Mon, 14 Mar 2022 13:27:09 +0000.")
        end
      end

      it "formats the date rightfully in French" do
        I18n.with_locale("fr") do
          travel_to "2022-03-14 13:27:09 +0000" do
            expect(email).to have_html_part_content("Envoyé le 14 mars 2022 13h 27min 09s.")
            expect(email).to have_text_part_content("Envoyé le 14 mars 2022 13h 27min 09s.")
          end
        end
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
      it_behaves_like "a translated email"

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
      it_behaves_like "a translated email"

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
        expect(email).to have_html_part_content("Hi <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
        expect(email).to have_html_part_content("> has been flagged by our automated system")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Hi #{user.login},")
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
        expect(email).to have_html_part_content("Hi <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Hi #{user.login},")
      end
    end
  end

  describe "#archivist_added_to_collection_notification" do
    subject(:email) do
      UserMailer.archivist_added_to_collection_notification(user.id, work.id, collection.id)
    end

    let(:collection) { create(:collection) }
    let(:user) { create(:user) }
    let(:work) { create(:work, authors: [user.pseuds.first]) }

    # Test the headers
    it_behaves_like "an email with a valid sender"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] An Open Doors archivist has added your work to a collection"
      expect(email.subject).to eq(subject)
    end

    # Test both body contents
    it_behaves_like "a multipart email"

    it_behaves_like "a translated email"

    describe "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Hi <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
        expect(email).to have_html_part_content(collection.title)
        expect(email).to have_html_part_content(work.title)
      end
    end

    describe "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Hi #{user.login},")
        expect(email).to have_text_part_content(collection.title)
        expect(email).to have_text_part_content(work.title)
      end
    end
  end

  describe "recipient_notification" do
    context "when collection is present" do
      subject(:email) { UserMailer.recipient_notification(user.id, work.id, collection.id) }

      let(:user) { create(:user) }
      let(:work) { create(:work, fandom_string: "Fandom 1, Fandom 2", character_string: "A, B") }
      let(:collection) { create(:collection) }

      # Test the headers
      it_behaves_like "an email with a valid sender"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] A gift work for you from #{collection.title}"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      it_behaves_like "a translated email"

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

      it_behaves_like "a translated email"

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

  describe "#no_potential_matches_notification" do
    subject(:email) { UserMailer.no_potential_matches_notification(collection.id, "test@example.com") }

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
    subject(:email) { UserMailer.no_potential_matches_notification(collection.id, collection.collection_email) }

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

  describe "prompter_notification" do
    let(:user) { create(:user) }

    context "when collection is present" do
      subject(:email) { UserMailer.prompter_notification(user.id, work.id, collection.id) }

      let(:collection) { create(:collection) }
      let(:claim) { create(:challenge_claim, request_signup: create(:prompt_meme_signup)) }
      let(:work) { create(:work, challenge_claims: [claim]) }

      # Test the headers
      it_behaves_like "an email with a valid sender"
      it_behaves_like "a translated email"

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
      subject(:email) { UserMailer.prompter_notification(user.id, work.id) }

      let(:claim) { create(:challenge_claim, request_signup: create(:prompt_meme_signup)) }
      let(:work) { create(:work, challenge_claims: [claim]) }

      # Test the headers
      it_behaves_like "an email with a valid sender"
      it_behaves_like "a translated email"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] A response to your prompt"
        expect(email).to have_subject(subject)
      end

      # Test both body contents
      it_behaves_like "a multipart email"

      describe "HTML version" do
        it "has the correct content" do
          expect(email).to have_html_part_content("posted on the Archive")
          expect(email).not_to have_html_part_content("collection")
        end
      end

      describe "text version" do
        it "has the correct content" do
          expect(email).to have_text_part_content("posted on the Archive")
          expect(email).not_to have_text_part_content("collection")
        end
      end
    end
  end

  describe "delete_work_notification" do
    subject(:email) { UserMailer.delete_work_notification(user, work, user) }

    let(:user) { create(:user) }
    let(:work) { create(:work) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a translated email"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Your work has been deleted"
      expect(email).to have_subject(subject)
    end

    it "has the correct attachments" do
      filename = work.title.gsub(/\s/, "_")
      expect(email.attachments.length).to eq(2)
      expect(email.attachments).to contain_exactly(
        an_object_having_attributes(filename: "#{filename}.html"),
        an_object_having_attributes(filename: "#{filename}.txt")
      )
    end

    context "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Hi <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
        expect(email).to have_html_part_content("was deleted at your request")
      end
    end

    context "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Hi #{user.login},")
        expect(email).to have_text_part_content("Your work \"#{work.title}\" was deleted at your request")
      end
    end

    context "when work has posted and draft chapters" do
      let!(:draft_chapter) { create(:chapter, :draft, work: work, position: 2) }

      it_behaves_like "an email with a deleted work with draft chapters attached"
    end

    context "when work has only draft chapters" do
      before do
        work.chapters.first.update_column(:posted, false)
      end

      it_behaves_like "an email with a deleted work with draft chapters attached"
    end
  end

  describe "admin_deleted_work_notification" do
    subject(:email) { UserMailer.admin_deleted_work_notification(user, work) }

    let(:user) { create(:user) }
    let(:work) { create(:work) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a translated email"

    it "has the correct subject line" do
      subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Your work has been deleted by an administrator"
      expect(email).to have_subject(subject)
    end

    it "has the correct attachments" do
      filename = work.title.gsub(/\s/, "_")
      expect(email.attachments.length).to eq(2)
      expect(email.attachments).to contain_exactly(
        an_object_having_attributes(filename: "#{filename}.html"),
        an_object_having_attributes(filename: "#{filename}.txt")
      )
    end

    context "HTML version" do
      it "has the correct content" do
        expect(email).to have_html_part_content("Hi <b")
        expect(email).to have_html_part_content("#{user.login}</b>,")
        expect(email).to have_html_part_content("was deleted by an AO3 administrator")
      end

      it "includes ToS violation warning with links" do
        expect(email).to have_html_part_content("you may not repost the work")
        expect(email).to have_html_part_content("Terms of Service")
        expect(email).to have_html_part_content("Content Policy")
        expect(email).to have_html_part_content("Terms of Service FAQ")
      end

      it "instructs user to check email and contact Policy & Abuse" do
        expect(email).to have_html_part_content("check your email")
        expect(email).to have_html_part_content("spam folder")
        expect(email).to have_html_part_content("contact the Policy & Abuse committee")
      end

      it "directs users to Policy & Abuse in footer" do
        expect(email).to have_html_part_content("Policy & Abuse")
        expect(email).not_to have_html_part_content("contact Support")
      end
    end

    context "text version" do
      it "has the correct content" do
        expect(email).to have_text_part_content("Hi #{user.login},")
        expect(email).to have_text_part_content("Your work \"#{work.title}\" was deleted by an AO3 administrator")
      end

      it "includes ToS violation warning with URLs" do
        expect(email).to have_text_part_content("you may not repost the work")
        expect(email).to have_text_part_content("/tos),")
        expect(email).to have_text_part_content("/content),")
        expect(email).to have_text_part_content("/tos_faq#repost_my_work")
      end

      it "instructs user to check email and contact Policy & Abuse" do
        expect(email).to have_text_part_content("check your email")
        expect(email).to have_text_part_content("spam folder")
        expect(email).to have_text_part_content("contact the Policy & Abuse committee")
        expect(email).to have_text_part_content("/abuse_reports/new")
      end

      it "directs users to Policy & Abuse in footer" do
        expect(email).to have_text_part_content("Policy & Abuse")
        expect(email).not_to have_text_part_content("contact Support")
      end
    end

    context "when work has posted and draft chapters" do
      let!(:draft_chapter) { create(:chapter, :draft, work: work, position: 2) }

      it_behaves_like "an email with a deleted work with draft chapters attached"
    end

    context "when work has only draft chapters" do
      before do
        work.chapters.first.update_column(:posted, false)
      end

      it_behaves_like "an email with a deleted work with draft chapters attached"
    end
  end
end
