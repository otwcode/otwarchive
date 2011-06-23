require 'spec_helper'

describe User do

  describe "save" do
  
    before(:each) do
      @user = User.new
      @user.login = "myname"
      @user.age_over_13 = "1"
      @user.terms_of_service = "1"
      @user.email = "foo1@archiveofourown.org"
      @user.password = "password"
    end
    
    it "should save a minimalistic user" do
      @user.save
      @user.save.should == true
  end
    
    it "should not save user with too short login" do
      @user.login = "a"
      @user.save.should == false
      @user.errors[:login].should_not be_empty
    end
    
  end

end
