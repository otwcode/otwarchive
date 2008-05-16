require File.dirname(__FILE__) + "/../spec_helper"

context = self

describe "FixtureReplacement" do
  it "should raise the error: 'Error in FixtureReplacement plugin: ..." do
    context.stub!(:require).and_raise(LoadError.new("could not find file!"))
    lambda {
      load File.dirname(__FILE__) + "/../../lib/fixture_replacement.rb"
    }.should raise_error(LoadError, "Error in FixtureReplacement Plugin: could not find file!")
  end
  
  it "should raise the error if the error is not a LoadError" do
    context.stub!(:require).and_raise(StandardError.new("foo"))
    lambda {
      load File.dirname(__FILE__) + "/../../lib/fixture_replacement.rb"
    }.should raise_error(StandardError, "foo")
  end
end