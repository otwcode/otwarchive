require 'spec/spec_helper'

describe Riddle::Client::Filter do
  it "should render a filter that uses an array of ints correctly" do
    filter = Riddle::Client::Filter.new("field", [1, 2, 3])
    filter.query_message.should == query_contents(:filter_array)
  end
  
  it "should render a filter that has exclude set correctly" do
    filter = Riddle::Client::Filter.new("field", [1, 2, 3], true)
    filter.query_message.should == query_contents(:filter_array_exclude)
  end
  
  it "should render a filter that is a range of ints correctly" do
    filter = Riddle::Client::Filter.new("field", 1..3)
    filter.query_message.should == query_contents(:filter_range)
  end
  
  it "should render a filter that is a range of ints as exclude correctly" do
    filter = Riddle::Client::Filter.new("field", 1..3, true)
    filter.query_message.should == query_contents(:filter_range_exclude)
  end
  
  it "should render a filter that is a range of floats correctly" do
    filter = Riddle::Client::Filter.new("field", 5.4..13.5)
    filter.query_message.should == query_contents(:filter_floats)
  end
  
  it "should render a filter that is a range of floats as exclude correctly" do
    filter = Riddle::Client::Filter.new("field", 5.4..13.5, true)
    filter.query_message.should == query_contents(:filter_floats_exclude)
  end
end