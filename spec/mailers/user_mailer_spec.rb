require 'spec_helper'

describe UserMailer do
  describe "basic user emails" do

    before(:each) do
      @user = User.new
      @user.login = "myname"
      @user.age_over_13 = "1"
      @user.terms_of_service = "1"
      @user.email = "foo1@archiveofourown.org"
      @user.password = "password"
      @user.activate
    end

    let(:email) { UserMailer.activation(@user.id).deliver }

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      email.encoded.should =~ /#{text}/
    end
  end
end