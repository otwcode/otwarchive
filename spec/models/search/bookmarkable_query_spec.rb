require 'spec_helper'

describe BookmarkableQuery do
  describe "#generated_query" do
    describe "a blank query" do
      let(:bookmark_query) { BookmarkQuery.new }
      let(:bookmarkable_query) { bookmark_query.bookmarkable_query }

      it "excludes hidden, draft, and restricted bookmarkables when logged out" do
        User.current_user = nil

        excluded = bookmarkable_query.generated_query.dig(:query, :bool, :must_not)
        expect(excluded).to include(term: { hidden_by_admin: "true" })
        expect(excluded).to include(term: { posted: "false" })
        expect(excluded).to include(term: { restricted: "true" })
      end

      it "excludes hidden and draft bookmarkables, but not restricted when logged in" do
        User.current_user = build_stubbed(:user)

        excluded = bookmarkable_query.generated_query.dig(:query, :bool, :must_not)
        expect(excluded).to include(term: { hidden_by_admin: "true" })
        expect(excluded).to include(term: { posted: "false" })
        expect(excluded).not_to include(term: { restricted: "true" })
      end

      it "excludes private and hidden bookmarks" do
        child_filter = bookmarkable_query.generated_query.dig(:query, :bool, :must)

        expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { hidden_by_admin: "false" })
        expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { private: "false" })
      end

      it "doesn't include aggregations" do
        aggregations = bookmarkable_query.generated_query[:aggs]
        expect(aggregations).to be_blank
      end
    end

    describe "a faceted query" do
      let(:bookmark_query) { BookmarkQuery.new(faceted: true) }
      let(:bookmarkable_query) { bookmark_query.bookmarkable_query }
      let(:aggregations) { bookmarkable_query.generated_query[:aggs] }

      Tag::FILTERS.each do |type|
        it "includes #{type.underscore.humanize.downcase} aggregations" do
          expect(aggregations[type.underscore]).to \
            include({ terms: { field: "#{type.underscore}_ids" } })
        end
      end

      it "includes aggregations for the bookmark tags" do
        # Top-level aggregation to get all children:
        expect(aggregations[:bookmarks]).to \
          include({ children: { type: "bookmark" } })

        # Nested aggregation to filter the children:
        expect(aggregations.dig(:bookmarks, :aggs, :filtered_bookmarks)).to \
          include({ filter: bookmarkable_query.bookmark_bool })

        # Nest even further to get the tags of the children:
        expect(aggregations.dig(:bookmarks, :aggs, :filtered_bookmarks, :aggs, :tag)).to \
          include({ terms: { field: "tag_ids" } })
      end
    end

    it "combines all bookmark filters (positive and negative) in a single has_child query" do
      bookmark_query = BookmarkQuery.new(user_ids: [5], excluded_bookmark_tag_ids: [666])
      q = bookmark_query.bookmarkable_query
      child_filter = q.generated_query.dig(:query, :bool, :must)
      expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { private: "false" })
      expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { user_id: 5 })
      expect(child_filter.dig(:has_child, :query, :bool, :must_not)).to include(terms: { tag_ids: [666] })
    end
  end
end
