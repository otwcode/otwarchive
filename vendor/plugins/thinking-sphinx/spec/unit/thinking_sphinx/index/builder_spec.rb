require 'spec/spec_helper'

describe ThinkingSphinx::Index::Builder do
  before :each do
    @builder = Class.new(ThinkingSphinx::Index::Builder)
    @builder.setup
  end
  
  describe "setup method" do
    it "should set up the information arrays and properties hash" do
      @builder.fields.should     == []
      @builder.attributes.should == []
      @builder.conditions.should == []
      @builder.groupings.should  == []
      @builder.properties.should == {}
    end
  end
  
  describe "indexes method" do
    
  end
  
  describe "has method" do
    
  end
  
  describe "where method" do
    
  end
  
  describe "set_property method" do
    
  end
end