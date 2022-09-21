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

  describe "#save" do
    let(:collection_item) { build(:collection_item, item: item, collection: collection) }

    shared_examples "automatic same-user approval" do
      context "when the collector is the item creator" do
        before { User.current_user = creator }

        it "is automatically approved by the user" do
          collection_item.save
          expect(collection_item.approved_by_user?).to be true
        end
      end
    end

    context "when the item is a work" do
      let(:item) { create(:work) }
      let(:creator) { item.pseuds.first.user }

      it_behaves_like "automatic same-user approval"
    end

    context "when the item is a bookmark" do
      let(:item) { create(:bookmark) }
      let(:creator) { item.pseud.user }

      it_behaves_like "automatic same-user approval"
    end
  end

  describe "creation validation" do
    shared_examples "passes validation" do
      it "proceeds without error" do
        expect(build(:collection_item, item: item, collection: collection)).to be_valid
      end
    end

    context "when the item is a work" do
      let(:item) { create(:work) }
      let(:creator) { item.pseuds.first.user }

      context "when the creator allows collection invitations" do
        before { creator.preference.update(allow_collection_invitation: true) }

        it_behaves_like "passes validation"
      end

      context "when the creator does not allow collection invitations" do
        context "when the collector is the work creator" do
          before { User.current_user = creator }

          it_behaves_like "passes validation"
        end

        context "when the collector is not the work creator" do
          it "returns a validation error" do
            expect(build(:collection_item, item: item, collection: collection)).not_to be_valid
          end
        end
      end
    end

    context "when the item is a bookmark" do
      let(:item) { create(:bookmark) }
      let(:creator) { item.pseud.user }

      context "when the creator allows collection invitations" do
        before { creator.preference.update(allow_collection_invitation: true) }

        it_behaves_like "passes validation"
      end

      context "when the creator does not allow collection invitations" do
        it_behaves_like "passes validation"
      end
    end
  end
end
