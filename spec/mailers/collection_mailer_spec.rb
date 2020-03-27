require 'spec_helper'

describe CollectionMailer do
  describe "item_added_notification" do
    let(:collection) { create(:collection, email: Faker::Internet.email) } 
    let(:work) { create(:work) }

    subject(:email) { CollectionMailer.item_added_notification(work.id, collection.id, "Work").deliver }

    it_behaves_like "an email with a valid sender"
  end
end
