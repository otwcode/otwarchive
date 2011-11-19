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
      @user.save.should be_true
    end

    it "should not save user without age_over_13 flag" do
      @user.age_over_13 = ""
      @user.save.should be_false
      @user.errors[:age_over_13].should_not be_empty
    end
    
    it "should not save user without terms_of_service flag" do
      @user.terms_of_service = ""
      @user.save.should be_false
      @user.errors[:terms_of_service].should_not be_empty
    end
    
    it "should encrypt password" do
      @user.save
      @user.crypted_password.should_not be_empty
      @user.crypted_password.should_not == @user.password
    end
    
    it "should not save user with too short login" do
      @user.login = "a"
      @user.save.should be_false
      @user.errors[:login].should_not be_empty
    end
    
    it "should not save user with too long login" do
      @user.login = "a" * 60
      @user.save.should be_false
      @user.errors[:login].should_not be_empty
    end

    it "should not save user when login exists already" do
      user2 = Factory.create(:user)
      @user.login = user2.login
      @user.save.should be_false
      @user.errors[:login].should_not be_empty
    end

    it "should not save user when email exists already" do
      user2 = Factory.create(:user)
      @user.email = user2.email
      @user.save.should be_false
      @user.errors[:email].should_not be_empty
    end

    it "should create default associateds" do
      @user.save
      @user.profile.should_not be_nil
      @user.preference.should_not be_nil
      @user.pseuds.size.should == 1
      @user.pseuds.first.name.should == @user.login
      @user.pseuds.first.is_default.should be_true
    end
    
  end


  describe "most_popular_tags" do
    
    before(:each) do
      @user = Factory.create(:user)
      @fandom1 = Factory.create(:fandom)
      @fandom2 = Factory.create(:fandom)
      @character = Factory.create(:character)
    end

    it "should be empty when user has no works" do
      @user.most_popular_tags.should be_empty
    end

    it "should find one fandom for one work" do
      Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom1] })

      @user.most_popular_tags.should == [@fandom1]
      @user.most_popular_tags.first.taggings_count.should == 1
    end
    
    it "should find two fandoms for one work" do
      Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom1, @fandom2] })

      @user.most_popular_tags.should =~ [@fandom1, @fandom2]
      @user.most_popular_tags.first.taggings_count.should == 1
      @user.most_popular_tags.last.taggings_count.should == 1
    end

    it "should find two fandoms for two works" do
      Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom1] })

      Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom2] })

      @user.most_popular_tags.should =~ [@fandom1, @fandom2]
      @user.most_popular_tags.first.taggings_count.should == 1
      @user.most_popular_tags.last.taggings_count.should == 1
    end

    it "should count duplicated fandoms" do
      Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom1] })

      Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom1, @fandom2] })

      @user.most_popular_tags.should == [@fandom1, @fandom2]
      @user.most_popular_tags.first.taggings_count.should == 2
      @user.most_popular_tags.last.taggings_count.should == 1
    end

    it "should find different kinds of tags" do
      Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom1],
                       :characters => [@character]})
      
      @user.most_popular_tags.should =~ [@fandom1, @character]
      @user.most_popular_tags.first.taggings_count.should == 1
      @user.most_popular_tags.last.taggings_count.should == 1
    end

    it "should limit to one kind of tags" do
     Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom1],
                       :characters => [@character]})
      
      @user.most_popular_tags(:categories => ["Character"]).should == [@character]
    end

  
    it "should limit length of returned collection" do
      Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom1] })

      Factory.create(:work,
                     { :authors => [@user.pseuds.first],
                       :fandoms => [@fandom1, @fandom2] })

      @user.most_popular_tags(:limit => 1).should == [@fandom1]
    end

  end
end
