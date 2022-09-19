require 'spec_helper'

describe CollectionItem, :ready do

  let(:collection) { create(:collection) }

  context "belonging to a bookmark" do
    let(:bookmark) { create(:bookmark) }

    before { bookmark.pseud.user.preference.update(allow_collection_invitation: true) }

    it "can be revealed without erroring" do
      collection_item = create(
        :collection_item,
        unrevealed: true,
        item: bookmark,
        collection: collection
      )
      collection_item.unrevealed = false
      expect(collection_item.save).to be_truthy
    end
  end

  describe "creation validation" do
    shared_examples "validate creator collection preference" do
      context "when the creator allows collection invitations" do
        before { creator.preference.update(allow_collection_invitation: true) }

        it "proceeds without error" do
          expect(build(:collection_item, item: item, collection: collection)).to be_valid
        end
      end

      context "when the creator does not allow collection invitations" do
        it "returns a validation error" do
          expect(build(:collection_item, item: item, collection: collection)).not_to be_valid
        end
      end
    end

    context "when the item is a work" do
      let(:item) { create(:work) }
      let(:creator) { item.pseuds.first.user }

      it_behaves_like "validate creator collection preference"
    end

    context "when the item is a bookmark" do
      let(:item) { create(:bookmark) }
      let(:creator) { item.pseud.user }

      it_behaves_like "validate creator collection preference"
    end
  end
end
