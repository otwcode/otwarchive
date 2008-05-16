require File.dirname(__FILE__) + "/../../../spec_helper"

module FixtureReplacementController
  describe MethodGenerator, "Evaluation loading" do
    before :each do
      @module = Module.new
      extend @module

      item_attributes = lambda do |o|
        o.category = default_category
      end
      
      writing_attributes = lambda do |w|
        w.name = "foo"
      end

      ClassFactory.stub!(:fixture_replacement_module).and_return @module
      @item_attributes = AttributeCollection.new(:item, :attributes => item_attributes)
      @writing_attributes = AttributeCollection.new(:writing, :from => :item, :attributes => writing_attributes, :class => Writing)
      AttributeCollection.new(:category)
    end

    it "should not raise an error if the a default_* method is referenced before it is defined" do
      lambda {
        MethodGenerator.generate_methods
      }.should_not raise_error
    end 
    
    it "should merge the hash with item and writing when new_writing is called" do
      MethodGenerator.generate_methods
      @writing_attributes.should_receive(:merge!)
      new_writing
    end   
    
    it "should merge the has with item and writing when create_writing is called" do
      MethodGenerator.generate_methods
      @writing_attributes.should_receive(:merge!)
      create_writing
    end
  end
end