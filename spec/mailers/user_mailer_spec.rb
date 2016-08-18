require 'spec_helper'

describe UserMailer do

  context "claim notification" do
    title = 'Imported Work Title'
    title2 = 'Second ' + title
    let(:author) { create(:user) }
    let(:work) { create(:work, title: title, authors: [author.pseuds.first]) }
    let(:work2) { create(:work, title: title2, authors: [author.pseuds.first]) }
    let(:email) { UserMailer.claim_notification(author.id, [work.id, work2.id], true).deliver }

    # Shared content tests for both email types
    shared_examples_for 'claim content' do
      it 'should contain the text for a claim email' do
        expect(part).to include("You're receiving this e-mail because you had works in a fanworks archive that has been imported")
      end
    end

    # Test the headers
    it 'should have a valid from line' do
      text = "Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.header['From'].to_s).to eq(text)
    end

    it 'should have the correct subject line' do
      text = "[#{ArchiveConfig.APP_SHORT_NAME}] Works uploaded"
      expect(email.subject).to eq(text)
    end

    # Test both body contents
    it_behaves_like "multipart email"

    describe 'HTML version' do
      it_behaves_like "claim content" do
        let(:part) { get_message_part(email, /html/) }
      end

      it 'should list the first imported work in an unordered list in the HTML body' do
        expect(get_message_part(email, /html/)).to have_xpath('//ul/li', text: title)
      end

      it 'should list the second imported work in an unordered list in the HTML body' do
        expect(get_message_part(email, /html/)).to have_xpath('//ul/li', text: title2)
      end

      it 'should only have style_to links in the HTML body' do
        expect(get_message_part(email, /html/)).not_to have_xpath('//a[not(@style)]')
      end
    end

    describe 'text version' do
      it_behaves_like 'claim content' do
        let(:part) { get_message_part(email, /plain/) }
      end

      it 'should list the first imported work as plain text' do
        expect(get_message_part(email, /plain/)).not_to have_xpath('//ul/li', text: title)
      end

      it 'should list the second imported work with a leading hyphen' do
        expect(get_message_part(email, /plain/)).to include('- ' + title2)
      end
    end
  end

  describe "invitation to claim" do
    title = 'Imported Work Title'
    title2 = 'Second ' + title
    token = 'abc123'

    before(:each) do
      @author = FactoryGirl.create(:user)
      @archivist = FactoryGirl.create(:user)
      @external_author = FactoryGirl.create(:external_author)
      @external_author_name = FactoryGirl.create(:external_author_name, external_author_id: @external_author.id, name: 'External Author')

      @invitation = FactoryGirl.create(:invitation, token: token, external_author_id: @external_author.id)
      @fandom1 = FactoryGirl.create(:fandom)

      @work = FactoryGirl.create(:work, title: title, fandoms: [@fandom1], authors: [@author.pseuds.first])
      @work2 = FactoryGirl.create(:work, title: title2, fandoms: [@fandom1], authors: [@author.pseuds.first])
      FactoryGirl.create(:external_creatorship, creation_id: @work.id, external_author_name_id: @external_author_name.id)
      FactoryGirl.create(:external_creatorship, creation_id: @work2.id, external_author_name_id: @external_author_name.id)
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
      it 'should contain the text for an invitation claim email' do
        expect(part).to include("You're receiving this e-mail because an archive has recently been imported by")
      end
    end

    # Test the headers
    it 'should have a valid from line' do
      text = "Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.header['From'].to_s).to eq(text)
    end

    it 'should have the correct subject line' do
      text = "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation to claim works"
      expect(email.subject).to eq(text)
    end

    # Test both body contents
    it_behaves_like "multipart email"

    describe 'HTML version' do
      it_behaves_like 'invitation to claim content' do
        let(:part) { get_message_part(email, /html/) }
      end

      it 'should list the first imported work in an unordered list in the HTML body' do
        expect(get_message_part(email, /html/)).to have_xpath('//ul/li', text: title)
      end

      it 'should list the second imported work in an unordered list in the HTML body' do
        expect(get_message_part(email, /html/)).to have_xpath('//ul/li', text: title2)
      end

      it 'should only have style_to links in the HTML body' do
        expect(get_message_part(email, /html/)).not_to have_xpath('//a[not(@style)]')
      end
    end

    describe 'text version' do
      it_behaves_like 'invitation to claim content' do
        let(:part) { get_message_part(email, /plain/) }
      end

      it 'should list the first imported work as plain text' do
        expect(get_message_part(email, /plain/)).not_to have_xpath('//ul/li', text: title)
      end

      it 'should list the second imported work with a leading hyphen' do
        expect(get_message_part(email, /plain/)).to include(title2)
      end
    end
  end
end
