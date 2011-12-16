require 'spec_helper'

describe Pseud do

  it "has a valid factory" do
    expect(build(:pseud)).to be_valid
  end

  it "is invalid without a name" do
    expect(build(:pseud, name: nil)).to be_invalid
  end

  it "is invalid if there are special characters" do
      expect(build(:pseud, name: '*pseud*')).to be_invalid
  end

  # TODO: add more tests

  describe "save" do
  
    before(:each) do
      @user = User.new
      @user.login = "myname"
      @user.age_over_13 = "1"
      @user.terms_of_service = "1"
      @user.email = "foo1@archiveofourown.org"
      @user.password = "password"
      @user.save
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
    
    it "should not save pseud with too-long comment text for icon" do
      @pseud.icon_comment_text = "Something that is too long blah blah blah blah blah blah blah blah blah blah blah blah blah blah"
      @pseud.save.should be_false
      @pseud.errors[:icon_comment_text].should_not be_empty
    end

  end

end
