require 'spec_helper'

describe CollectionMailer, type: :mailer do
  describe "basic collection emails" do

    before(:each) do
      @collection = FactoryBot.create(:collection)
      @collection.email = "test@testing.com"
      @collection.save
      @work = FactoryBot.create(:work)
    end

    let(:email) { CollectionMailer.item_added_notification(@work.id, @collection.id, "Work").deliver }

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.encoded).to match(/#{text}/)
    end
  end
end
