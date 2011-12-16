require 'spec_helper'

describe Pseud do

  describe "save" do

		before do
			@user = User.new
      @user.login = "mynamepseud"
      @user.age_over_13 = "1"
      @user.terms_of_service = "1"
      @user.email = "foo1@archiveofourown.org"
      @user.password = "password"
      @user.save
		end

    before(:each) do
      @pseud = Pseud.new
      @pseud.user_id = @user.id
      @pseud.name = "MyName"
    end
    
    it "should save a minimalistic pseud" do
      @pseud.should be_valid_verbose
      @pseud.save.should be_true
      @pseud.errors.should be_empty
    end

    it "should not save pseud with too-long alt text for icon" do
      @pseud.icon_alt_text = "Something that is too long blah blah blah blah blah blah blah blah blah blah blah blah blah blah"
      @pseud.save.should be_false
      @pseud.errors[:icon_alt_text].should_not be_empty
    end
    
    it "should not save pseud with too-long comment text for icon" #do
      #@pseud.icon_comment_text = "Something that is too long blah blah blah blah blah blah blah blah blah blah blah blah blah blah"
      #@pseud.save.should be_false
      #@pseud.errors[:icon_comment_text].should_not be_empty
    #end

  end

end
