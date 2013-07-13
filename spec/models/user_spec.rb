require 'spec_helper'

describe User do

  context "valid user" do

    let(:user) {build(:user)}
    it "should save a minimalistic user" do
      user.save.should be_true
    end

    let(:user) {build(:user)}
    it "should encrypt password" do
      user.save
      user.crypted_password.should_not be_empty
      user.crypted_password.should_not == user.password
    end

    let(:user) {build(:user)}
    it "should create default associateds" do
      user.save
      user.profile.should_not be_nil
      user.preference.should_not be_nil
      user.pseuds.size.should == 1
      user.pseuds.first.name.should == user.login
      user.pseuds.first.is_default.should be_true
    end

  end

  describe "User Validations" do
    context "missing age_over_13 flage" do
      let(:no_age_over_13) {build(:user, age_over_13: "0")}
      it "should not save user" do
        no_age_over_13.save.should be_false
        no_age_over_13.errors[:age_over_13].should_not be_empty
      end
    end

    context "missing terms_of_service flag" do
      let(:no_tos) {build(:user, terms_of_service: "0")}
      it "should not save user" do
        no_tos.save.should be_false
        no_tos.errors[:terms_of_service].should_not be_empty
      end
    end

    context "login length" do
      let(:login_short) {build(:user, login: ArchiveConfig.LOGIN_LENGTH_MIN - 1)}
      it "should not save user with too short login" do
        login_short.save.should be_false
        login_short.errors[:login].should_not be_empty
      end

      let(:login_long) {build(:user, login: ArchiveConfig.LOGIN_LENGTH_MAX + 1)}
      it "should not save user with too long login" do
        login_long.save.should be_false
        login_long.errors[:login].should_not be_empty
      end
    end


    context "password length" do
      let(:password_short) {build(:user, password: ArchiveConfig.PASSWORD_LENGTH_MIN - 1)}
      it "should not save user with too short login" do
        password_short.save.should be_false
        password_short.errors[:password].should_not be_empty
      end

      let(:password_long) {build(:user, password: ArchiveConfig.PASSWORD_LENGTH_MAX + 1)}
      it "should not save user with too long login" do
        password_long.save.should be_false
        password_long.errors[:password].should_not be_empty
      end
    end

    context "login format validation" do
      let(:begins_with_symbol) {}
      let(:ends_with_symbol){}
      let(:correct_format) {}
    end

    context "login or email exists" do

      before :all do
        @existing = create(:user)
      end

      let(:new) {build(:user, login: @existing.login)}
      it "should not save user when login exists already" do
        new.save.should be_false
        new.errors[:login].should_not be_empty
      end

      let(:new) {build(:duplicate_user, login: @existing.login)}
      it "should prevent duplicate logins even when Rails validation misses it" do
        lambda do
          # pass ':validate => false' to 'save' in order to skip the validations, to simulate race conditions
          new.save(:validate => false)
        end.should raise_error(ActiveRecord::RecordNotUnique)
      end

      let(:new) {build(:duplicate_user, email: @existing.email)}
      it "should not save user when email exists already" do
        new.save.should be_false
        new.errors[:email].should_not be_empty
      end

    end

  end
end


#  describe "most_popular_tags", :pending do
#
#    before(:each) do
#      @user = Factory.create(:user)
#      @fandom1 = Factory.create(:fandom)
#      @fandom2 = Factory.create(:fandom)
#      @character = Factory.create(:character)
#    end
#
#    it "should be empty when user has no works" do
#      @user.most_popular_tags.should be_empty
#    end
#
#    it "should find one fandom for one work" do
#      Factory.create(:work,
#                     { :authors => [@user.pseuds.first],
#                       :fandoms => [@fandom1] })
#
#      @user.most_popular_tags.should == [@fandom1]
#      @user.most_popular_tags.first.taggings_count.should == 1
#    end
#
#    it "should find two fandoms for one work" do
#      FactoryGirl.create(:work,
#                         { :authors => [@user.pseuds.first],
#                           :fandom_string => "#{@fandom1.name}, #{@fandom2.name}" })
#      @user.most_popular_tags.should =~ [@fandom1, @fandom2]
#      @user.most_popular_tags.first.taggings_count.should == 1
#      @user.most_popular_tags.last.taggings_count.should == 1
#    end
#
#    it "should find two fandoms for two works" do
#      FactoryGirl.create(:work,
#                         { :authors => [@user.pseuds.first],
#                           :fandom_string => @fandom1.name })
#      Factory.create(:work,
#                     { :authors => [@user.pseuds.first],
#                       :fandoms => [@fandom1] })
#
#      @user.most_popular_tags.should =~ [@fandom1, @fandom2]
#      @user.most_popular_tags.first.taggings_count.should == 1
#      @user.most_popular_tags.last.taggings_count.should == 1
#    end
#
#    it "should count duplicated fandoms" do
#      Factory.create(:work,
#                     { :authors => [@user.pseuds.first],
#                       :fandoms => [@fandom1] })
#
#      Factory.create(:work,
#                     { :authors => [@user.pseuds.first],
#                       :fandoms => [@fandom1, @fandom2] })
#
#      @user.most_popular_tags.should == [@fandom1, @fandom2]
#      @user.most_popular_tags.first.taggings_count.should == 2
#      @user.most_popular_tags.last.taggings_count.should == 1
#    end
#
#    it "should find different kinds of tags" do
#      Factory.create(:work,
#                     { :authors => [@user.pseuds.first],
#                       :fandoms => [@fandom1],
#                       :characters => [@character]})
#      @user.most_popular_tags.should =~ [@fandom1, @character]
#      @user.most_popular_tags.first.taggings_count.should == 1
#      @user.most_popular_tags.last.taggings_count.should == 1
#    end
#
#    it "should limit to one kind of tags" do
#     Factory.create(:work,
#                     { :authors => [@user.pseuds.first],
#                       :fandoms => [@fandom1],
#                       :characters => [@character]})
#      @user.most_popular_tags(:categories => ["Character"]).should == [@character]
#    end
#
#
#    it "should limit length of returned collection" do
#      FactoryGirl.create(:work,
#                         { :authors => [@user.pseuds.first],
#                           :fandom_string => "#{@fandom1.name}, #{@fandom2.name}" })
#      Factory.create(:work,
#                     { :authors => [@user.pseuds.first],
#                       :fandoms => [@fandom1, @fandom2] })
#      @user.most_popular_tags(:limit => 1).should == [@fandom1]
#    end
#
#end
