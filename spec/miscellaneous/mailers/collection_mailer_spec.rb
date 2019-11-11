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

    it_behaves_like "an email with a valid sender"
  end
end
