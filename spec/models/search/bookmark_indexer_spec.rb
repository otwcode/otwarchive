require "spec_helper"

describe BookmarkIndexer, bookmark_search: true do
  describe "#index_documents" do
    let(:bookmark) { create(:bookmark) }
    let(:indexer) { BookmarkIndexer.new([bookmark.id]) }

    context "when the bookmarker of one of the bookmarks has no user" do
      before { bookmark.pseud.user.delete }

      it "doesn't error" do
        expect { indexer.index_documents }.not_to raise_exception
      end
    end

    context "with multiple bookmarks in a batch", :n_plus_one do
      let(:collection) { create(:collection) }

      populate do |n|
        bookmarks = create_list(:bookmark, n, tag_string: "Fluff") +
                    create_list(:external_work_bookmark, n)
        bookmarks.each { |bookmark| bookmark.collections << collection }
      end

      it "generates a constant number of database queries" do
        expect do
          BookmarkIndexer.new(Bookmark.ids).index_documents
        end.to perform_constant_number_of_queries
      end
    end
  end
end
