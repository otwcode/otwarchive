require File.dirname(__FILE__) + "/../../spec_helper"

module FixtureReplacementController
  describe AttributeCollection do  
    it "should add the instance to the global attributes" do
      a = AttributeCollection.new(:foo)
      AttributeCollection.instances.should == [a]
    end
    
    it "should have no instances when none have been created" do
      AttributeCollection.instances.should == []
    end
    
    it "should have two instances when two have been created" do
      a1 = AttributeCollection.new(:foo)
      a2 = AttributeCollection.new(:foo)
      AttributeCollection.instances.should == [a1, a2]
    end
    
    it "should have the fixture name as accessible" do
      a1 = AttributeCollection.new(:foo)
      a1.fixture_name.should == :foo
    end
    
    it "should have the from attribute as nil, if none provided" do
      a1 = AttributeCollection.new(:foo)
      a1.from.should be_nil
    end
    
    it "should have the from attribute as the symbol of the attribute from which it derives" do
      a1 = AttributeCollection.new(:foo, :from => :bar)
      a1.from.should == :bar
    end
    
    it "should be able to find the Attribute by fixture name" do
      a = AttributeCollection.new(:baz)
      AttributeCollection.find_by_fixture_name(:baz).should == a
    end
    
    it "should find no attributes for fixture_name :baz, if it was never created" do
      a = AttributeCollection.new(:bar)
      AttributeCollection.find_by_fixture_name(:baz).should be_nil
    end
    
    it "should find no attributes for fixture_name :baz, if no fixture at all was ever created" do
      AttributeCollection.find_by_fixture_name(:baz).should be_nil
    end
    
    it "should have the class name if specified" do
      AttributeCollection.new(:foo, :class => Object).active_record_class.should == Object
    end
    
    it "should use the class name of the fixture_name, camel-cased, if the class is unspecified, and the fixture uninherited" do
      AttributeCollection.new(:object).active_record_class.should == Object
    end
    
    it "should use the class name of the inherited attribute, if specified" do
      AttributeCollection.new(:foo, :class => Object)
      AttributeCollection.new(:bar, :from => :foo).active_record_class.should == Object      
    end    
    
    it "should not raise an error if the model ends with 's'" do
      AttributeCollection.new(:actress).active_record_class.should == Actress
    end
  end  
  
  describe AttributeCollection, "hash, with simple arguments (only attributes and fixture name)" do
    
    it "should return a hash" do
      AttributeCollection.new(:foo).hash.should == {}
    end
    
    it "should return the attributes hash given" do
      @struct = OpenStruct.new
      @struct.foo = :bar
      @struct.scott = :taylor
      attributes = AttributeCollection.new(:foo, :attributes => lambda do |f|
        f.foo = :bar
        f.scott = :taylor
      end)
      
      attributes.hash.should == {
        :foo => :bar,
        :scott => :taylor
      }
    end
  end
  
  module AttributeFromHelper
    def setup_attributes
      @from_attributes_as_struct = lambda { |u| u.first_name = :scott }
      @from_attributes = AttributeCollection.new(:foo, :attributes => @from_attributes_as_struct)
    end
  end
  
  describe AttributeCollection, "with an empty hash, after merge with another inherited attribute" do    
    include AttributeFromHelper
    
    before :each do
      setup_attributes
      @attributes = AttributeCollection.new(:bar, :from => :foo)
    end
    
    it "should contain the keys from the inherited hash only" do
      @attributes.merge!
      @attributes.hash.should == {
        :first_name => :scott
      }
    end
  end
  
  describe AttributeCollection, "with a hash, after merge with another inherited attributes" do
    include AttributeFromHelper
    
    before :each do
      setup_attributes      
    end
    
    it "should overwrite an attribute" do
      open_struct = lambda { |os| os.first_name = :scott }
      
      attributes = AttributeCollection.new :bar, :from => :foo, :attributes => open_struct
      
      attributes.merge!
      attributes.hash.should == {:first_name => :scott}
    end
    
    it "should keep any new attributes, as well as any attributes which weren't overwritten" do
      open_struct = lambda { |os| os.foo = :bar }
      
      attributes = AttributeCollection.new(:bar, :from => :foo, :attributes => open_struct)
      
      attributes.merge!
      attributes.hash.should == {:foo => :bar, :first_name => :scott}      
    end
  end  
end
