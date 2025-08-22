require "spec_helper"

describe Bookmarkable do
  describe "reindexing" do
    let!(:parent_collection) { create(:collection) }
    let!(:collection) { create_invalid(:collection, parent: parent_collection) }

    context "when bookmark of bookmarkable already exists" do
      [:work, :external_work, :series].each do |bookmarkable_type|
        let!(:bookmarkable) { create(bookmarkable_type) }
        let!(:bookmark) { create(:bookmark, bookmarkable: bookmarkable, collections: [collection]) }

        context "when #{bookmarkable_type} is hidden by an admin" do
          it "enqueues its collection for reindex" do
            expect do
              bookmarkable.update!(hidden_by_admin: true)
            end.to add_to_reindex_queue(collection, :background) &
                   add_to_reindex_queue(parent_collection, :background)
          end
        end

        context "when #{bookmarkable_type} is not significantly changed" do
          it "doesn't enqueue its collection for reindex" do
            expect do
              bookmarkable.touch
            end.to not_add_to_reindex_queue(collection, :background) &
                   not_add_to_reindex_queue(parent_collection, :background)
          end
        end

        context "when #{bookmarkable_type} is destroyed" do
          it "enqueues its collection for reindex" do
            expect do
              bookmarkable.destroy!
            end.to add_to_reindex_queue(collection, :background) &
                   add_to_reindex_queue(parent_collection, :background)
          end
        end
      end
    end
  end
end
