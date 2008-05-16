require File.dirname(__FILE__) + "/../../../spec_helper"

module FixtureReplacementController
  describe MethodGenerator do
    before :each do
      @user_attributes = mock("UserAttributeCollection")
      @user_attributes.stub!(:merge!)
      @module = mock("FixtureReplacement")
      ClassFactory.stub!(:fixture_replacement_module).and_return @module
      @generator = MethodGenerator.new(@user_attributes)
    end
    
    it "should have the class method generate_methods" do
      MethodGenerator.should respond_to(:generate_methods)
    end
        
    it "should be able to respond to generate_default_method" do
      @generator.should respond_to(:generate_default_method)
    end

    it "should respond to generate_create_method" do
      @generator.should respond_to(:generate_create_method)
    end

    it "should respond to generate_new_method" do
      @generator.should respond_to(:generate_new_method)
    end
  end
end