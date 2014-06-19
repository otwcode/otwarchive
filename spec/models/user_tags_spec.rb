require 'spec_helper'

describe User do
  describe "most_popular_tags", :wip do

    before(:each) do
      @user = create(:user)
      @fandom1 = create(:fandom)
      @fandom2 = create(:fandom)
      @character = create(:character)
    end

    it "should be empty when user has no works" do
      @user.most_popular_tags.should be_empty
    end

    it "should find one fandom for one work" do
      create(:work,{ :authors => [@user.pseuds.first],
                     :fandoms => [@fandom1] })

      @user.most_popular_tags.should == [@fandom1]
      @user.most_popular_tags.first.taggings_count.should == 1
    end

    it "should find two fandoms for one work" do
      create(:work,{ :authors => [@user.pseuds.first],
                     :fandom_string => "#{@fandom1.name}, #{@fandom2.name}" })
      @user.most_popular_tags.should =~ [@fandom1, @fandom2]
      @user.most_popular_tags.first.taggings_count.should == 1
      @user.most_popular_tags.last.taggings_count.should == 1
    end

    it "should find two fandoms for two works" do
      @pseud = @user.pseuds.first
      create(:work, { :authors => [@pseud],
                      :fandom_string => @fandom1.name })
      create(:work, { :authors => [@pseud],
                      :fandom_string => [@fandom2.name] })
      @user.most_popular_tags.should =~ [@fandom1, @fandom2]
      @user.most_popular_tags.first.taggings_count.should == 1
      @user.most_popular_tags.last.taggings_count.should == 1
    end

    it "should count duplicated fandoms" do
      create(:work, { :authors => [@user.pseuds.first],
                      :fandoms => [@fandom1] })

      create(:work, { :authors => [@user.pseuds.first],
                      :fandoms => [@fandom1, @fandom2] })

      @user.most_popular_tags.should == [@fandom1, @fandom2]
      @user.most_popular_tags.first.taggings_count.should == 2
      @user.most_popular_tags.last.taggings_count.should == 1
    end

    it "should find different kinds of tags" do
      create(:work, { :authors => [@user.pseuds.first],
                      :fandoms => [@fandom1],
                      :characters => [@character]})
      @user.most_popular_tags.should =~ [@fandom1, @character]
      @user.most_popular_tags.first.taggings_count.should == 1
      @user.most_popular_tags.last.taggings_count.should == 1
    end

    it "should limit to one kind of tags" do
      create(:work, { :authors => [@user.pseuds.first],
                      :fandoms => [@fandom1],
                      :characters => [@character]})
      @user.most_popular_tags(:categories => ["Character"]).should == [@character]
    end


    it "should limit length of returned collection" do
      create(:work, { :authors => [@user.pseuds.first],
                      :fandom_string => "#{@fandom1.name}, #{@fandom2.name}" })
      create(:work, { :authors => [@user.pseuds.first],
                      :fandoms => [@fandom1, @fandom2] })
      @user.most_popular_tags(:limit => 1).should == [@fandom1]
    end

  end
end