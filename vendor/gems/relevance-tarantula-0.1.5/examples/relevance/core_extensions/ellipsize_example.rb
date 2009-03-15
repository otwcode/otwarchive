require File.join(File.dirname(__FILE__), "../..", "example_helper.rb")

describe "Relevance::CoreExtensions::Object#ellipsize" do
  it "converts nil to empty string" do
    nil.ellipsize.should == ""
  end
  
  it "doesn't touch short strings" do
    "hello".ellipsize.should == "hello"
  end
  
  it "calls inspect on non-strings" do
    [1,2,3].ellipsize.should == "[1, 2, 3]"
  end

  it "shortens long strings and adds ..." do
    "long-string".ellipsize(5).should == "long-..."
  end
end