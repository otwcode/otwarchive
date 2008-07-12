require 'spec/spec_helper'

describe "Sphinx Searches" do
  before :each do
    @client = Riddle::Client.new("localhost", 3313)
  end
  
  it "should return a single hash if a single query" do
    @client.query("smith").should be_kind_of(Hash)
  end
  
  it "should return an array of hashs if multiple queries are run" do
    @client.append_query "smith"
    @client.append_query "jones"
    results = @client.run
    results.should be_kind_of(Array)
    results.each { |result| result.should be_kind_of(Hash) }
  end
  
  it "should return an array of matches" do
    matches = @client.query("smith")[:matches]
    matches.should be_kind_of(Array)
    matches.each { |match| match.should be_kind_of(Hash) }
  end
  
  it "should return an array of string fields" do
    fields = @client.query("smith")[:fields]
    fields.should be_kind_of(Array)
    fields.each { |field| field.should be_kind_of(String) }
  end
  
  it "should return an array of attribute names" do
    attributes = @client.query("smith")[:attribute_names]
    attributes.should be_kind_of(Array)
    attributes.each { |a| a.should be_kind_of(String) }
  end
  
  it "should return a hash of attributes" do
    attributes = @client.query("smith")[:attributes]
    attributes.should be_kind_of(Hash)
    attributes.each do |key,value|
      key.should be_kind_of(String)
      value.should be_kind_of(Integer)
    end
  end
  
  it "should return the total number of results returned" do
    @client.query("smith")[:total].should be_kind_of(Integer)
  end
  
  it "should return the total number of results available" do
    @client.query("smith")[:total_found].should be_kind_of(Integer)
  end
  
  it "should return the time taken for the query as a float" do
    @client.query("smith")[:time].should be_kind_of(Float)
  end
  
  it "should return a hash of the words from the query, with the number of documents and the number of hits" do
    words = @client.query("smith victoria")[:words]
    words.should be_kind_of(Hash)
    words.each do |word,hash|
      word.should be_kind_of(String)
      hash.should be_kind_of(Hash)
      hash[:docs].should be_kind_of(Integer)
      hash[:hits].should be_kind_of(Integer)
    end
  end
end