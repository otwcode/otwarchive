require "spec_helper"

describe CollectionQuery do
  it "allows you to perform a simple search" do
    q = CollectionQuery.new(title: "test")
    search_body = q.generated_query
    query = search_body.dig(:query).first
    expect(query[1][:query]).to eq("test")
    expect(query[1][:default_operator]).to eq("AND")
  end

  it "sorts by created_at by default" do
    q = CollectionQuery.new
    expect(q.generated_query[:sort]).to eq({"created_at" => { order: "desc" }})
  end

  it "allows you to sort by title" do
    q = CollectionQuery.new(sort_column: "title", sort_direction: "asc")
    expect(q.generated_query[:sort]).to eq({"title" => { order: "asc" }})
  end

  it "allows you to filter for collections with open signup" do
    q = CollectionQuery.new(signup_open: "true")
    expect(q.filters).to include(term: { "signup_open": true })
  end

  it "allows you to filter for collections that are closed" do
    q = CollectionQuery.new(closed: "false")
    expect(q.filters).to include(term: { closed: false })
  end
end
