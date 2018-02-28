require 'spec_helper'

describe BookmarkableQuery do
  describe "#add_bookmark_filters" do
    it "should take a default has_parent query and flip it around" do
      bookmark_query = BookmarkQuery.new
      q = BookmarkableQuery.new
      q.bookmark_query = bookmark_query
      q.add_bookmark_filters
      excluded = q.generated_query.dig(:query, :bool, :filter, :bool, :must_not)
      expect(excluded).to include(term: { restricted: "true" })
      expect(excluded).to include(term: { hidden_by_admin: "true" })
      expect(excluded).to include(term: { posted: "false" })
    end

    it "should take bookmark filters and combine them into one child query" do
      bookmark_query = BookmarkQuery.new(user_ids: [5], excluded_tag_ids: [666])
      q = BookmarkableQuery.new
      q.bookmark_query = bookmark_query
      q.add_bookmark_filters
      filters = q.generated_query.dig(:query, :bool, :filter, :bool, :must)
      child_filter = filters.detect { |f| f.key?(:has_child) }
      expect(child_filter.dig(:has_child, :query, :bool, :must)).to include(term: { private: "false" })
      expect(child_filter.dig(:has_child, :query, :bool, :must)).to include(term: { user_id: 5 })
      expect(child_filter.dig(:has_child, :query, :bool, :must_not)).to include(term: { tag_ids: 666 })
    end
  end
end
