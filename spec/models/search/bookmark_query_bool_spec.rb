require 'spec_helper'

describe BookmarkQuery do
  let(:any_field_query) { { query_string: { query: "unicorns -rainbows", default_operator: "AND" } } }
  let(:bookmarker_query) { { query_string: { query: "bookmarker:testy", default_operator: "AND" } } }
  let(:bookmark_notes_query) { { query_string: { query: "notes:Notes", default_operator: "AND" } } }
  let(:tag_query) { { query_string: { query: "tag:\"foo\"", default_operator: "AND" } } }
  let(:tag2_query) { { query_string: { query: "tag:\"bar\"", default_operator: "AND" } } }
  let(:parent_query) { { has_parent: { parent_type: "bookmarkable", query: tag_query } } }
  let(:parent2_query) { { has_parent: { parent_type: "bookmarkable", query: tag2_query } } }
  
  it "performs a simple search on either the bookmark or the bookmarkable" do
    expected = {
      bool: {
        must: [
          {
            bool: {
              should: [any_field_query,
                       { has_parent: { parent_type: "bookmarkable", query: any_field_query } }
              ]
            }
          }
        ]
      }
    }
    q = BookmarkQuery.new(query: "unicorns -rainbows")
    search_body = q.generated_query
    expect(search_body[:query][:bool][:must]).to include(expected)
  end
  
  it "searches for bookmarker ONLY on the bookmark" do
    q = BookmarkQuery.new(bookmarker: "testy")
    search_body = q.generated_query
    expect(search_body[:query][:bool][:must][:bool][:must].first).to eq(bookmarker_query)
  end
  
  it "searches for bookmark notes ONLY on the bookmark" do
    q = BookmarkQuery.new(bookmark_notes: "Notes")
    search_body = q.generated_query
    expect(search_body[:query][:bool][:must][:bool][:must].first).to eq(bookmark_notes_query)
  end
  
  it "searches for tags on both bookmark and bookmarkable" do
    q = BookmarkQuery.new(tag: "foo")
    search_body = q.generated_query
    tags_query = search_body[:query][:bool][:must][:bool][:must].first[:bool][:should]
    
    expect(tags_query.size).to eq(2)
    expect(tags_query).to include(tag_query)
    expect(tags_query).to include(parent_query)
  end
  
  it "searches for multiple tags individually on both bookmark and bookmarkable" do
    q = BookmarkQuery.new(tag: "foo bar")
    search_body = q.generated_query
    tags_query = search_body[:query][:bool][:must][:bool][:must]

    expect(tags_query.size).to eq(2)
    expect(tags_query.first[:bool][:should]).to include(tag_query)
    expect(tags_query.first[:bool][:should]).to include(parent_query)
    expect(tags_query.second[:bool][:should]).to include(tag2_query)
    expect(tags_query.second[:bool][:should]).to include(parent2_query)
  end

  it "searches for all tags on bookmark, bookmarkable or both" do
    q = BookmarkQuery.new(query: "unicorns -rainbows", bookmarker: "testy", bookmark_notes: "Notes", tag: "foo bar")
    search_body = q.generated_query
    tags_query = search_body[:query][:bool][:must][:bool][:must]

    expect(tags_query.first[:bool][:should].first).to eq(any_field_query)
    expect(tags_query.second).to eq(bookmarker_query)
    expect(tags_query[2]).to eq(bookmark_notes_query)
    expect(tags_query[3][:bool][:should]).to include(tag_query)
    expect(tags_query[3][:bool][:should]).to include(parent_query)
    expect(tags_query[4][:bool][:should]).to include(tag2_query)
    expect(tags_query[4][:bool][:should]).to include(parent2_query)
  end
end
