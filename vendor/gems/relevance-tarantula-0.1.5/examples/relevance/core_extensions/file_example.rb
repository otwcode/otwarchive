require File.join(File.dirname(__FILE__), "../..", "example_helper.rb")
require 'relevance/core_extensions/file'

describe "Relevance::CoreExtensions::File#extension" do
  it "should return the extension without the leading dot" do
    File.extension("foo.bar").should == "bar"
  end
end