require File.dirname(__FILE__) + "/../../../spec_helper"

module FixtureReplacementController  
  module MethodGeneratorHelper
    def setup_for_generate_new_method(fixture_name, classname)
      @module = Module.new
      ClassFactory.stub!(:fixture_replacement_module).and_return @module
      extend @module

      @fixture_name = fixture_name
      @class = classname
      
      @attributes = AttributeCollection.new(@fixture_name, {
        :attributes => lambda do |f|
          f.key = "val"
        end
      })
      
      @generator = MethodGenerator.new(@attributes)
      @generator.generate_new_method
    end
  end
  
  describe "MethodGenerator#generate_new_method", :shared => true do
    it "should respond to new_user in the module" do
      @module.instance_methods.should include("new_#{@fixture_name}")
    end

    it "should return a new User object" do
      obj = @class.new
      @class.stub!(:new).and_return obj
      self.send("new_#{@fixture_name}").should == obj
    end

    it "should return a new User object with the keys given in user_attributes" do
      self.send("new_#{@fixture_name}").key.should == "val"
    end

    it "should over-write the User's hash with any hash given to new_user" do
      self.send("new_#{@fixture_name}", :key => "other_value").key.should == "other_value"
    end

    it "should add any hash key-value pairs which weren't previously given in user_attributes" do
      u = self.send("new_#{@fixture_name}", :other_key => "other_value")
      u.key.should == "val"
      u.other_key.should == "other_value"
    end 

    it "should not be saved to the database" do
      self.send("new_#{@fixture_name}").should be_a_new_record
    end   

    it "should be able to be saved to the database" do
      lambda {
        self.send("new_#{@fixture_name}").save!
      }.should_not raise_error      
    end
  end

  describe MethodGenerator, "generate_new_method for User" do
    include MethodGeneratorHelper
    
    before :each do
      setup_for_generate_new_method(:user, User)
    end

    it_should_behave_like "MethodGenerator#generate_new_method"
  end

  describe MethodGenerator, "generate_new_method for Admin" do
    include MethodGeneratorHelper
    
    before :each do
      setup_for_generate_new_method(:admin, Admin)
    end
  
    it_should_behave_like "MethodGenerator#generate_new_method"
  end
  
  describe MethodGenerator, "generate_new_method with associations" do
  
    def create_generator(fixture_name, attributes)
      generator = MethodGenerator.new(attributes)
      generator.generate_default_method
      generator.generate_new_method
      generator.generate_create_method
    end
  
    before :each do
      @module = Module.new
      ClassFactory.stub!(:fixture_replacement_module).and_return @module
      extend @module
      
      gender_attributes = AttributeCollection.new(:gender, :attributes => lambda do |gender| 
        gender.sex = "Male"
      end)
      
      user_attributes = AttributeCollection.new(:user, :attributes => lambda do |user|
        user.gender = default_gender
      end)
      
      alien_attributes = AttributeCollection.new(:alien, :attributes => lambda do |alien|
        alien.gender = default_gender(:sex => "unknown")
      end)
      
      create_generator(:gender, gender_attributes)
      create_generator(:user, user_attributes)
      create_generator(:alien, alien_attributes)
    end
    
    it "should evaluate any of the default_* methods before returning (if no over-writing key is given)" do
      new_gender = new_user.gender
      new_gender.sex.should == "Male"
    end
    
    it %(should evaluate any of the default_* methods before returning, with the hash params given to default_* method) do
      new_gender = new_alien.gender
      new_gender.sex.should == "unknown"
    end
    
    it "should call Gender.save! when the default_gender method is evaluated by default_gender" do
      @gender = mock('Gender', :null_object => true)
      Gender.stub!(:new).and_return @gender
      @user = mock('User')
      @user.stub!(:gender=).and_return @gender
      User.stub!(:new).and_return @user
    
      @gender.should_receive(:save!)
      new_user
    end
    
    it "should not call Gender.save! if the default_gender is overwritten by another value" do
      Gender.should_not_receive(:save!)
      new_user(:gender => Gender.new)
    end
    
    it "should be able to overwrite a default_* method" do
      Gender.should_not_receive(:save!)
      new_user(:gender => Gender.create!(:sex => "Female"))
    end
  end
end


