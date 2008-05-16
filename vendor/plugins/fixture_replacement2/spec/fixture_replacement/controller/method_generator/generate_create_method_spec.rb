require File.dirname(__FILE__) + "/../../../spec_helper"

module FixtureReplacementController
  describe "MethodGenerator#generate_create_method with valid attributes", :shared => true do
    it "should save the user with save!" do
      @user = mock(@class, :null_object => true)
      @user.stub!(:save!).and_return true      
      @class.stub!(:new).and_return @user
      
      @user.should_receive(:save!).with(no_args)
      self.send("create_#{@fixture_name}")
    end
    
    it "should return a kind of the fixture name" do
      self.send("create_#{@fixture_name}").should be_a_kind_of(@class)
    end
    
    it "should return a type (User, Admin,...) which has been saved" do
      self.send("create_#{@fixture_name}").should_not be_a_new_record
    end
    
    it "should user the default hash parameters, if none are given" do
      user = self.send("create_#{@fixture_name}")
      user.key.should == @hash[:key]
      user.username.should == @hash[:username]
    end
    
    it "should be able to overwrite the hash with the parameters given" do
      user = self.send("create_#{@fixture_name}", @hash.merge(:username => "smtlaissezfaire"))
      user.key.should == @hash[:key]
      user.username.should == "smtlaissezfaire"      
    end
  end
  
  describe "MethodGenerator#generate_create_method", :shared => true do
    it "should generate the method new_user" do
      @module.instance_methods.should include("new_#{@fixture_name}")
    end    
    
    it "should generate the method create_fixture_name in the module" do
      @module.instance_methods.should include("create_#{@fixture_name}")
    end
    
    it "should generate the method create_fixture_name which can take an optional hash 
        (it actually takes any number of params, but only uses the first hash given)" do      
      self.method("create_#{@fixture_name}").arity.should == -1
    end
  end

  describe MethodGenerator, "generate_create_method for User when user_attributes is defined (and valid)" do
    before :each do 
      @module = Module.new
      extend @module
      
      @fixture_name = :user
      @struct = lambda { |u| 
        u.username = "scott"
        u.key = "val"
      }

      @attributes = AttributeCollection.new(@fixture_name, :attributes => @struct)
      @attributes.stub!(:merge!)
      
      ClassFactory.stub!(:fixture_replacement_module).and_return @module
      @generator = MethodGenerator.new(@attributes)
      @generator.generate_new_method
      @generator.generate_create_method
      
      @hash = {:username => "scott", :key => "val"}
      @class = User
    end
    
    it_should_behave_like "MethodGenerator#generate_create_method"   
    it_should_behave_like "MethodGenerator#generate_create_method with valid attributes" 
  end
  
  describe MethodGenerator, "generate_create_method for Admin" do
    before :each do 
      @module = Module.new
      extend @module
      
      @fixture_name = :admin
      @struct = lambda { |a|
        a.username = "scott"
        a.key = "val"
      }

      @attributes = AttributeCollection.new(@fixture_name, :attributes => @struct)
      @attributes.stub!(:merge!)
      
      ClassFactory.stub!(:fixture_replacement_module).and_return @module
      @generator = MethodGenerator.new(@attributes)
      @generator.generate_new_method
      @generator.generate_create_method
      
      @hash = {:username => "scott", :key => "val"}
      @class = Admin
    end
    
    it_should_behave_like "MethodGenerator#generate_create_method"
    it_should_behave_like "MethodGenerator#generate_create_method with valid attributes" 
  end

  describe MethodGenerator, "generate_create_method for User when user_attributes is defined, but not valid" do
    before :each do 
      @module = Module.new
      extend @module

      @fixture_name = :user
      @struct = lambda { |u| u.key = nil }

      @attributes = AttributeCollection.new(@fixture_name, :attributes => @struct )
      @attributes.stub!(:merge!)

      ClassFactory.stub!(:fixture_replacement_module).and_return @module
      @generator = MethodGenerator.new(@attributes)
      @generator.generate_new_method
      @generator.generate_create_method

      @hash = {:key => nil}
      @class = User
    end

    it_should_behave_like "MethodGenerator#generate_create_method"

    it "should not create the record after executing create_user when the user's attributes are invalid
        (it should raise an ActiveRecord::RecordInvalid error)" do
      @generator.generate_create_method
      lambda {
        create_user(:key => nil)
      }.should raise_error(ActiveRecord::RecordInvalid)      
    end
  end
end