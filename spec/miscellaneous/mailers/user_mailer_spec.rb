require 'spec_helper'

describe UserMailer, type: :mailer do

  context "claim notification" do
    title = 'Imported Work Title'
    title2 = 'Second ' + title
    let(:author) { create(:user) }
    let(:work) { create(:work, title: title, authors: [author.pseuds.first]) }
    let(:work2) { create(:work, title: title2, authors: [author.pseuds.first]) }
    let(:email) { UserMailer.claim_notification(author.id, [work.id, work2.id], true).deliver }

    # Shared content tests for both email types
    shared_examples_for 'claim content' do
      it 'contains the text for a claim email' do
        expect(part).to include("You're receiving this e-mail because you had works in a fanworks archive that has been imported")
      end
    end

    # Test the headers
    it 'has a valid from line' do
      text = "Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.header['From'].to_s).to eq(text)
    end

    it 'has the correct subject line' do
      text = "[#{ArchiveConfig.APP_SHORT_NAME}] Works uploaded"
      expect(email.subject).to eq(text)
    end

    # Test both body contents
    it_behaves_like "multipart email"

    describe 'HTML version' do
      it_behaves_like "claim content" do
        let(:part) { get_message_part(email, /html/) }
      end

      it 'lists the first imported work in an unordered list in the HTML body' do
        expect(get_message_part(email, /html/)).to have_xpath('//ul/li', text: title)
      end

      it 'lists the second imported work in an unordered list in the HTML body' do
        expect(get_message_part(email, /html/)).to have_xpath('//ul/li', text: title2)
      end

      it 'only has style_to links in the HTML body' do
        expect(get_message_part(email, /html/)).not_to have_xpath('//a[not(@style)]')
      end
    end

    describe 'text version' do
      it_behaves_like 'claim content' do
        let(:part) { get_message_part(email, /plain/) }
      end

      it 'lists the first imported work as plain text' do
        expect(get_message_part(email, /plain/)).not_to have_xpath('//ul/li', text: title)
      end

      it 'lists the second imported work with a leading hyphen' do
        expect(get_message_part(email, /plain/)).to include('- ' + title2)
      end
    end
  end

  describe "invitation to claim" do
    title = 'Imported Work Title'
    title2 = 'Second ' + title
    token = 'abc123'

    before(:each) do
      @author = FactoryBot.create(:user)
      @archivist = FactoryBot.create(:user)
      @external_author = FactoryBot.create(:external_author)
      @external_author_name = FactoryBot.create(:external_author_name, external_author_id: @external_author.id, name: 'External Author')

      @invitation = FactoryBot.create(:invitation, token: token, external_author_id: @external_author.id)
      @fandom1 = FactoryBot.create(:fandom)

      @work = FactoryBot.create(:work, title: title, fandoms: [@fandom1], authors: [@author.pseuds.first])
      @work2 = FactoryBot.create(:work, title: title2, fandoms: [@fandom1], authors: [@author.pseuds.first])
      FactoryBot.create(:external_creatorship, creation_id: @work.id, external_author_name_id: @external_author_name.id)
      FactoryBot.create(:external_creatorship, creation_id: @work2.id, external_author_name_id: @external_author_name.id)
    end

    # before(:all) doesn't get cleaned up by database cleaner
    after(:all) do
      @author.destroy if @author
      @archivist.destroy if @archivist
      @external_author.destroy if @external_author
      @external_author_name.destroy if @external_author_name

      @invitation.destroy if @invitation
      @fandom1.destroy if @fandom1

      @work.destroy if @work
      @work2.destroy if @work2
    end

    let(:email) { UserMailer.invitation_to_claim(@invitation.id, @archivist.login).deliver }

    # Shared content tests for both email types
    shared_examples_for 'invitation to claim content' do
      it 'contains the text for an invitation claim email' do
        expect(part).to include("You're receiving this e-mail because an archive has recently been imported by")
      end
    end

    # Test the headers
    it 'has a valid from line' do
      text = "Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.header['From'].to_s).to eq(text)
    end

    it 'has the correct subject line' do
      text = "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation to claim works"
      expect(email.subject).to eq(text)
    end

    # Test both body contents
    it_behaves_like "multipart email"

    describe 'HTML version' do
      it_behaves_like 'invitation to claim content' do
        let(:part) { get_message_part(email, /html/) }
      end

      it 'lists the first imported work in an unordered list in the HTML body' do
        expect(get_message_part(email, /html/)).to have_xpath('//ul/li', text: title)
      end

      it 'lists the second imported work in an unordered list in the HTML body' do
        expect(get_message_part(email, /html/)).to have_xpath('//ul/li', text: title2)
      end

      it 'only has style_to links in the HTML body' do
        expect(get_message_part(email, /html/)).not_to have_xpath('//a[not(@style)]')
      end

      it 'does not have exposed HTML' do
        expect(get_message_part(email, /html/)).not_to include("&lt;")
      end

      it 'does not have missing translations' do
        expect(get_message_part(email, /html/)).not_to include("translation missing")
      end
    end

    describe 'text version' do
      it_behaves_like 'invitation to claim content' do
        let(:part) { get_message_part(email, /plain/) }
      end

      it 'lists the first imported work as plain text' do
        expect(get_message_part(email, /plain/)).not_to have_xpath('//ul/li', text: title)
      end

      it 'lists the second imported work with a leading hyphen' do
        expect(get_message_part(email, /plain/)).to include(title2)
      end

      it 'does not have missing translations' do
        expect(get_message_part(email, /plain/)).not_to include("translation missing")
      end
    end
  end
  
  describe "invitation from a user request" do
    token = 'abc123'

    before(:each) do
      @user = FactoryBot.create(:user)
      @invitation = FactoryBot.create(:invitation, token: token, creator: @user)
    end

    let(:email) { UserMailer.invitation(@invitation.id).deliver }

    # Test the headers
    it 'has a valid from line' do
      text = "Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.header['From'].to_s).to eq(text)
    end

    it 'has the correct subject line' do
      text = "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation"
      expect(email.subject).to eq(text)
    end

    # Test both body contents
    it_behaves_like "multipart email"

    describe 'HTML version' do
      it 'has text contents' do
        expect(get_message_part(email, /html/)).to include("like to join us, please sign up at the following address")
        expect(get_message_part(email, /html/)).to include("has invited you")
      end
      
      it 'does not have missing translations' do
        expect(get_message_part(email, /html/)).not_to include("translation missing")
      end
    end

    describe 'text version' do
      it 'says the right thing' do
        expect(get_message_part(email, /plain/)).to include("like to join us, please sign up at the following address")
        expect(get_message_part(email, /plain/)).to include("has invited you")
      end
      
      it 'does not have missing translations' do
        expect(get_message_part(email, /plain/)).not_to include("translation missing")
      end
    end
  end
  
  describe "invitation" do
    token = 'abc123'

    before(:each) do
      @user = FactoryBot.create(:user)
      @invitation = FactoryBot.create(:invitation, token: token)
    end

    let(:email) { UserMailer.invitation(@invitation.id).deliver }

    # Test the headers
    it 'has a valid from line' do
      text = "Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.header['From'].to_s).to eq(text)
    end

    it 'has the correct subject line' do
      text = "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation"
      expect(email.subject).to eq(text)
    end

    # Test both body contents
    it_behaves_like "multipart email"

    describe 'HTML version' do
      it 'has text contents' do
        expect(get_message_part(email, /html/)).to include("like to join us, please sign up at the following address")
        expect(get_message_part(email, /html/)).to include("been invited")
      end
      
      it 'does not have missing translations' do
        expect(get_message_part(email, /html/)).not_to include("translation missing")
      end
      
      it 'does not have exposed HTML' do
        expect(get_message_part(email, /html/)).not_to include("&lt;")
      end
    end

    describe 'text version' do
      it 'says the right thing' do
        expect(get_message_part(email, /plain/)).to include("like to join us, please sign up at the following address")
        expect(get_message_part(email, /plain/)).to include("been invited")
      end
      
      it 'does not have missing translations' do
        expect(get_message_part(email, /plain/)).not_to include("translation missing")
      end
    end
  end

  describe "challenge assignment" do
    let!(:gift_exchange) { create(:gift_exchange) }
    let!(:collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let!(:otheruser) { create(:user) }
    let!(:offer) { create(:challenge_signup, collection: collection, pseud: otheruser.default_pseud) }
    let!(:open_assignment) { create(:challenge_assignment, collection: collection, offer_signup: offer) }

    let(:email) { UserMailer.challenge_assignment_notification(collection.id, otheruser.id, open_assignment.id).deliver }

    # Test the headers
    it 'has a valid from line' do
      text = "Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.header['From'].to_s).to eq(text)
    end

    it 'has the correct subject line' do
      text = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Your Assignment!"
      expect(email.subject).to eq(text)
    end

    # Test both body contents
    it_behaves_like "multipart email"

    describe 'HTML version' do
      it 'has text contents' do
        expect(get_message_part(email, /html/)).to include("You have been assigned the following request")
      end
      
      it 'does not have missing translations' do
        expect(get_message_part(email, /html/)).not_to include("translation missing")
      end
      
      it 'does not have exposed HTML' do
        expect(get_message_part(email, /html/)).not_to include("&lt;")
      end
    end

    describe 'text version' do
      it 'says the right thing' do
        expect(get_message_part(email, /plain/)).to include("You have been assigned the following request")
      end
      
      it 'does not have missing translations' do
        expect(get_message_part(email, /plain/)).not_to include("translation missing")
      end
    end
  end

  describe "invite request declined" do
    before(:each) do
      @user = FactoryBot.create(:user)
      @total = 2
      @reason = "You smell"
    end

    let(:email) { UserMailer.invite_request_declined(@user.id, @total, @reason).deliver }

    # Test the headers
    it 'has a valid from line' do
      text = "Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.header['From'].to_s).to eq(text)
    end

    it 'has the correct subject line' do
      text = "[#{ArchiveConfig.APP_SHORT_NAME}] Additional Invite Code Request Declined"
      expect(email.subject).to eq(text)
    end

    # Test both body contents
    it_behaves_like "multipart email"

    describe 'HTML version' do
      it 'has text contents' do
        expect(get_message_part(email, /html/)).to include("We regret to inform you that your request for 2 new invitations cannot be fulfilled at this time")
      end
      
      it 'does not have missing translations' do
        expect(get_message_part(email, /html/)).not_to include("translation missing")
      end
      
      it 'does not have exposed HTML' do
        expect(get_message_part(email, /html/)).not_to include("&lt;")
      end
    end

    describe 'text version' do
      it 'says the right thing' do
        expect(get_message_part(email, /plain/)).to include("We regret to inform you that your request for 2 new invitations cannot be fulfilled at this time")
      end
      
      it 'does not have missing translations' do
        expect(get_message_part(email, /plain/)).not_to include("translation missing")
      end
    end
  end
end
