require 'spec_helper'

describe CollectionQuery do

  it "should allow you to perform a simple search" do
    q = CollectionQuery.new(title: "test")
    search_body = q.generated_query
    query = search_body.dig(:query).first
    expect(query[1][:query]).to eq("test")
    expect(query[1][:default_operator]).to eq("AND")
  end

  it "should sort by created_at by default" do
    q = CollectionQuery.new
    expect(q.generated_query[:sort]).to eq({'created_at' => { order: 'desc' }})
  end

  it "should allow you to sort by title" do
    q = CollectionQuery.new(sort_column: 'title', sort_direction: 'asc')
    expect(q.generated_query[:sort]).to eq({'title' => { order: 'asc'}})
  end

  it "should allow you to filter for collections with open signup" do
    q = CollectionQuery.new(signup_open: 'true')
    expect(q.filters).to include(term: { "signup_open": true })
  end

  it "should allow you to filter for collections that are closed" do
    q = CollectionQuery.new(closed: 'false')
    expect(q.filters).to include(term: { closed: false})
  end

  it "should allow you to filter for moderated collections" do
    q = CollectionQuery.new(moderated: 'true')
    expect(q.filters).to include(term: { moderated: true })
  end

  it "should allow you to filter for moderated collections" do
    q = CollectionQuery.new(unrevealed: 'true')
    expect(q.filters).to include(term: { unrevealed: true })
  end

  it "should allow you to filter for non-anonymous collections" do
    q = CollectionQuery.new(anonymous: 'false')
    expect(q.filters).to include(term: { anonymous: false })
  end
end
