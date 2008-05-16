require File.dirname(__FILE__) + "/../../spec_helper"

describe "String.random" do
  it "should not be the same as another randomly generated string" do
    String.random.should_not == String.random
  end
  
  it "should by default be 10 characters long" do
    String.random.size.should == 10
  end
  
  it "should be able to specify the length of the random string" do
    String.random(100).size.should == 100
  end
  
  it "should only generate lowercase letters" do
    s = String.random(100)
    s.upcase.should == s.swapcase
  end
end