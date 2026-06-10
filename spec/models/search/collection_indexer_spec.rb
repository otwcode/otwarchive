require "spec_helper"

describe CollectionIndexer do
  describe "#document" do
    let(:collection) { create(:collection) }

    context "when the collection contains a private bookmark" do
      let(:bookmark) { create(:bookmark, private: true) }

      before do
        bookmark.collections << collection
      end

      it "is not counted for logged in users or guests" do
        document = described_class.new([]).document(collection)
        expect(document["general_bookmarked_items_count"]).to eq(0)
        expect(document["public_bookmarked_items_count"]).to eq(0)
      end
    end

    context "when the collection contains a bookmark of a restricted work" do
      let(:work) { create(:work, restricted: true) }
      let(:bookmark) { create(:bookmark, bookmarkable: work) }

      before do
        bookmark.collections << collection
      end

      it "is counted for logged in users only" do
        document = described_class.new([]).document(collection)
        expect(document["general_bookmarked_items_count"]).to eq(1)
        expect(document["public_bookmarked_items_count"]).to eq(0)
      end
    end

    context "when the collection contains a restricted work" do
      let(:work) { create(:work, restricted: true) }

      before do
        work.collections << collection
      end

      it "is counted for logged in users only" do
        document = described_class.new([]).document(collection)
        expect(document["general_works_count"]).to eq(1)
        expect(document["public_works_count"]).to eq(0)
      end
    end

    context "when the collection contains a subcollection" do
      let(:subcollection) { create(:collection) }
      let(:work) { create(:work) }
      let(:bookmark) { create(:bookmark) }

      before do
        subcollection.parent = collection
        subcollection.save!(validate: false)
        work.collections << subcollection
        bookmark.collections << subcollection
      end

      it "counts items in the subcollection" do
        document = described_class.new([]).document(collection)
        expect(document["general_bookmarked_items_count"]).to eq(1)
        expect(document["public_bookmarked_items_count"]).to eq(1)
        expect(document["general_works_count"]).to eq(1)
        expect(document["public_works_count"]).to eq(1)
      end
    end

    context "when the collection contains two bookmarks of one item" do
      let(:work) { create(:work) }
      let(:bookmark) { create(:bookmark, bookmarkable: work) }
      let(:bookmark2) { create(:bookmark, bookmarkable: work) }

      before do
        bookmark.collections << collection
        bookmark2.collections << collection
      end

      it "counts as one item" do
        document = described_class.new([]).document(collection)
        expect(document["general_bookmarked_items_count"]).to eq(1)
        expect(document["public_bookmarked_items_count"]).to eq(1)
      end
    end

    context "when the collection contains one private and one public bookmark of one item" do
      let(:work) { create(:work) }
      let(:bookmark) { create(:bookmark, bookmarkable: work) }
      let(:bookmark2) { create(:bookmark, bookmarkable: work, private: true) }

      before do
        bookmark.collections << collection
        bookmark2.collections << collection
      end

      it "counts as one item" do
        document = described_class.new([]).document(collection)
        expect(document["general_bookmarked_items_count"]).to eq(1)
        expect(document["public_bookmarked_items_count"]).to eq(1)
      end
    end
  end

  describe "#index_documents", collection_search: true do
    context "with multiple collections in a batch", :n_plus_one do
      populate { |n| create_list(:collection, n, challenge: create(:gift_exchange)) }

      it "generates about 8 database queries per collection" do
        expect do
          CollectionIndexer.new(Collection.ids).index_documents
        end.to perform_linear_number_of_queries(slope: 8) # The eight works/bookmarked items count queries which can't be eliminated with includes
      end
    end
  end
end
