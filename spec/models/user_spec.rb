require 'spec_helper'

describe User do

  it "should create a new user" do
    user = User.create(:login => "myname",
                        :age_over_13 => true,
                        :terms_of_service => true,
                        :email => "foo1@archiveofourown.org",
                        :password => "password")
    user.login.should == "myname"
  end

end