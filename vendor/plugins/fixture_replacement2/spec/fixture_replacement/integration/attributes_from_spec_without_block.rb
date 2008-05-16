require File.dirname(__FILE__) + "/../../spec_helper"

module FixtureReplacementControllerHelper
  def setup_fixtures
    @module = Module.new do
      class << self
        include FixtureReplacement::ClassMethods
      end
      
      attributes_for :user do |u|
        u.username = random_string
        u.key = String.random
      end

      attributes_for :scott, :from => :user
      
      attributes_for :foo, :class => User
      
      attributes_for :admin do |a|
        a.admin_status = true
      end
      
    private
    
      def random_string
        String.random
      end
    end

    FixtureReplacementController::ClassFactory.stub!(:fixture_replacement_module).and_return @module
    FixtureReplacementController::MethodGenerator.generate_methods
    self.class.send :include, @module
  end
end

module FixtureReplacementController
  describe AttributeCollection do
    include FixtureReplacementControllerHelper
    
    before :each do
      setup_fixtures
    end
    
    models = "user", "foo", "scott"
    
    models.each do |model|
      it "should have the default_#{model} as a (module) method on the module" do
        @module.should respond_to("default_#{model}")
      end
      
      it "should have the default_#{model} as a private method in the test case" do
        self.private_methods.should include("default_#{model}")
      end
      
      it "should have the new_#{model} method as a (module) method on the module" do
        @module.should respond_to("new_#{model}")
      end
      
      it "should have the new_#{model} method as a private method in the test case" do
        self.private_methods.should include("new_#{model}")
      end 

      it "should have the create_#{model} method as a private method in the test case" do
        self.private_methods.should include("create_#{model}")
      end
      
      it "should have the create_#{model} method as a (module) method on the module" do
        @module.should respond_to("create_#{model}")
      end
    end
    
    it "should have the username as a string (for User) for new_user" do
      new_user.username.class.should == String
    end
    
    it "should have the username as a string (for User) for create_user" do
      create_user.username.class.should == String
    end
  end
end