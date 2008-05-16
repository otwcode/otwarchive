require File.dirname(__FILE__) + "/../../spec_helper"

describe OpenStruct, "to_hash" do
  it "should return the hash it works with" do
    OpenStruct.new({:foo => :bar}).to_hash.should == {:foo => :bar}
  end
end