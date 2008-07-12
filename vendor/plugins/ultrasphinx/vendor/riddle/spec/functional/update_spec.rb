require 'spec/spec_helper'

describe "Sphinx Updates" do
  before :each do
    @client = Riddle::Client.new("localhost", 3313)
  end
  
  it "should update a single record appropriately" do
    # check existing birthday
    result = @client.query("Ellie K Ford")
    result[:matches].should_not be_empty
    result[:matches].length.should == 1
    ellie = result[:matches].first
    ellie[:attributes]["birthday"].should == Time.local(1970, 1, 23).to_i
    
    # make Ellie younger by 6 years
    @client.update("people", ["birthday"], {ellie[:doc] => [Time.local(1976, 1, 23).to_i]})
    
    # check attribute's value
    result = @client.query("Ellie K Ford")
    result[:matches].should_not be_empty
    result[:matches].length.should == 1
    ellie = result[:matches].first
    ellie[:attributes]["birthday"].should == Time.local(1976, 1, 23).to_i
  end
  
  it "should update multiple records appropriately" do
    result = @client.query("Steele")
    pairs = {}
    result[:matches].each do |match|
      pairs[match[:doc]] = [match[:attributes]["birthday"] + (365*24*60*60)]
    end
    
    @client.update "people", ["birthday"], pairs
    
    result = @client.query("Steele")
    result[:matches].each do |match|
      match[:attributes]["birthday"].should == pairs[match[:doc]].first
    end
  end
end