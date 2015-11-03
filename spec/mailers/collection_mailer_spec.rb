require 'spec_helper'

describe CollectionMailer do
  describe "basic collection emails" do

    before(:each) do
      @collection = FactoryGirl.create(:collection)
      @collection.email = "test@testing.com"
      @collection.save
      @work = FactoryGirl.create(:work)
    end

    let(:email) { CollectionMailer.item_added_notification(@work, @collection, "Work").deliver }

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.encoded).to match(/#{text}/)
    end
  end
end
