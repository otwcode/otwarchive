require File.dirname(__FILE__) + "/../spec_helper"

describe FixtureReplacement do
  before :each do
    @klass = Class.new
    undefine_methods :create_user, :new_user, :default_user, :user_attributes
        
    FixtureReplacement.module_eval do
      def user_attributes
        {
          
        }
      end
    end
  end
  
  def undefine_methods(*methods)
    methods.each do |method_name|
      if FixtureReplacement.instance_methods.include?(method_name.to_s)
        FixtureReplacement.send(:undef_method, method_name)
      end
    end
  end
  
  it "should generate the methods when included" do
    FixtureReplacementController::MethodGenerator.should_receive(:generate_methods).with(no_args)
    
    @klass.class_eval do
      include FixtureReplacement
    end
  end
  
  it "should not generate the methods before being included" do
    @klass.instance_methods.should_not include("create_user")
    @klass.instance_methods.should_not include("new_user")
    @klass.instance_methods.should_not include("default_user")
  end
  
end

describe FixtureReplacement, "including the module" do
  def remove_constant(constant)
    Object.send(:remove_const, constant) if Object.send(:const_defined?, constant)
  end
  
  before :each do
    @klass = Class.new
    remove_constant(:RAILS_ENV)
    FixtureReplacement.reset_excluded_environments!
  end
  
  after :each do
    remove_constant(:RAILS_ENV)
  end
  
  it "should raise an error if RAILS_ENV is production" do
    Object.const_set(:RAILS_ENV, "production")
    lambda { 
      @klass.class_eval do
        include FixtureReplacement
      end
    }.should raise_error(FixtureReplacement::InclusionError, "FixtureReplacement cannot be included in the production environment!")
  end
  
  it "should raise an error if RAILS_ENV is in staging, and the excluded_environments includes staging" do
    FixtureReplacement.excluded_environments = ["production", "staging"]
    Object.const_set(:RAILS_ENV, "staging")
    lambda {
      @klass.class_eval do
        include FixtureReplacement
      end
    }.should raise_error(FixtureReplacement::InclusionError, "FixtureReplacement cannot be included in the staging environment!")
  end
  
  it "should have the method environment_is_in_excluded_environments? as private" do
    FixtureReplacement.private_methods.should include("environment_is_in_excluded_environments?")
  end
end

describe FixtureReplacement do
  before :each do
    FixtureReplacement.reset_excluded_environments!
  end
  
  it "should by default have the excluded environments as just the production environment" do
    FixtureReplacement.excluded_environments.should == ["production"]
  end
  
  it "should be able to set the excluded environments" do
    FixtureReplacement.excluded_environments = ["production", "staging"]
    FixtureReplacement.excluded_environments.should == ["production", "staging"]
  end
end