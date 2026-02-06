# frozen_string_literal: true

require "spec_helper"

describe Bookmark do
  it "has a valid factory" do
    expect(build(:bookmark)).to be_valid
  end

  it "has a valid factory for external work bookmarks" do
    expect(build(:external_work_bookmark)).to be_valid
  end

  it "has a valid factory for series bookmarks" do
    expect(build(:series_bookmark)).to be_valid
  end

  it "is invalid without a pseud_id" do
    bookmark = build(:bookmark, pseud_id: nil)
    expect(bookmark).to_not be_valid
    expect(bookmark.errors[:pseud].first).to eq("can't be blank")
  end

  it "can be tagged if has an id larger than unsigned int" do
    bookmark = build(:bookmark, tag_string: "Huge", id: 5_294_967_295)
    expect(bookmark).to be_valid
    expect(bookmark.save).to be_truthy
    expect(bookmark.reload.taggings.last.tagger.name).to eq("Huge")
  end

  it "can be collected if has an id larger than unsigned int" do
    collection = create(:collection)
    bookmark = build(:bookmark, collection_names: collection.name, id: 5_294_967_295)
    expect(bookmark).to be_valid
    expect(bookmark.save).to be_truthy
    expect(bookmark.collections).to include(collection)
    expect(collection.bookmarks).to include(bookmark)
  end

  it "can be hidden if has an id larger than unsigned int" do
    bookmark = create(:bookmark, id: 5_294_967_295)
    admin = create(:admin)
    activity = build(:admin_activity, admin: admin, target: bookmark)

    expect(activity).to be_valid
    expect(activity.save).to be_truthy
    expect(activity.target_name).to eq("Bookmark #{bookmark.id}")
  end

  context "reindexing" do
    let!(:parent_collection) { create(:collection) }
    let!(:collection) { create_invalid(:collection, parent: parent_collection) }

    context "when bookmark is created in collection" do
      it "enqueues the collection for reindex" do
        expect do
          create(:bookmark, collections: [collection])
        end.to add_to_reindex_queue(collection, :background) &
               add_to_reindex_queue(parent_collection, :background)
      end
    end

    context "when bookmark already exists in the collection" do
      let!(:bookmark) { create(:bookmark, collections: [collection]) }

      context "when bookmark is hidden by an admin" do
        it "enqueues its collection for reindex" do
          expect do
            bookmark.update!(hidden_by_admin: true)
          end.to add_to_reindex_queue(collection, :background) &
                 add_to_reindex_queue(parent_collection, :background)
        end
      end

      context "when bookmark is privated" do
        it "enqueues its collection for reindex" do
          expect do
            bookmark.update!(private: true)
          end.to add_to_reindex_queue(collection, :background) &
                 add_to_reindex_queue(parent_collection, :background)
        end
      end

      context "when bookmark is not significantly changed" do
        it "doesn't enqueue its collection for reindex" do
          expect do
            bookmark.touch
          end.to not_add_to_reindex_queue(collection, :background) &
                 not_add_to_reindex_queue(parent_collection, :background)
        end
      end

      context "when bookmark is destroyed" do
        it "enqueues its collection for reindex" do
          expect do
            bookmark.destroy!
          end.to add_to_reindex_queue(collection, :background) &
                 add_to_reindex_queue(parent_collection, :background)
        end
      end
    end
  end
end
