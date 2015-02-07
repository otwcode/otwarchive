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
      expect(@user.most_popular_tags).to be_empty
    end

    it "should find one fandom for one work" do
      create(:work,{ authors: [@user.pseuds.first],
                     fandoms: [@fandom1] })

      expect(@user.most_popular_tags).to eq([@fandom1])
      expect(@user.most_popular_tags.first.taggings_count).to eq(1)
    end

    it "should find two fandoms for one work" do
      create(:work,{ authors: [@user.pseuds.first],
                     fandom_string: "#{@fandom1.name}, #{@fandom2.name}" })
      expect(@user.most_popular_tags).to match_array([@fandom1, @fandom2])
      expect(@user.most_popular_tags.first.taggings_count).to eq(1)
      expect(@user.most_popular_tags.last.taggings_count).to eq(1)
    end

    it "should find two fandoms for two works" do
      @pseud = @user.pseuds.first
      create(:work, { authors: [@pseud],
                      fandom_string: @fandom1.name })
      create(:work, { authors: [@pseud],
                      fandom_string: [@fandom2.name] })
      expect(@user.most_popular_tags).to match_array([@fandom1, @fandom2])
      expect(@user.most_popular_tags.first.taggings_count).to eq(1)
      expect(@user.most_popular_tags.last.taggings_count).to eq(1)
    end

    it "should count duplicated fandoms" do
      create(:work, { authors: [@user.pseuds.first],
                      fandoms: [@fandom1] })

      create(:work, { authors: [@user.pseuds.first],
                      fandoms: [@fandom1, @fandom2] })

      expect(@user.most_popular_tags).to eq([@fandom1, @fandom2])
      expect(@user.most_popular_tags.first.taggings_count).to eq(2)
      expect(@user.most_popular_tags.last.taggings_count).to eq(1)
    end

    it "should find different kinds of tags" do
      create(:work, { authors: [@user.pseuds.first],
                      fandoms: [@fandom1],
                      characters: [@character]})
      expect(@user.most_popular_tags).to match_array([@fandom1, @character])
      expect(@user.most_popular_tags.first.taggings_count).to eq(1)
      expect(@user.most_popular_tags.last.taggings_count).to eq(1)
    end

    it "should limit to one kind of tags" do
      create(:work, { authors: [@user.pseuds.first],
                      fandoms: [@fandom1],
                      characters: [@character]})
      expect(@user.most_popular_tags(categories: ["Character"])).to eq([@character])
    end


    it "should limit length of returned collection" do
      create(:work, { authors: [@user.pseuds.first],
                      fandom_string: "#{@fandom1.name}, #{@fandom2.name}" })
      create(:work, { authors: [@user.pseuds.first],
                      fandoms: [@fandom1, @fandom2] })
      expect(@user.most_popular_tags(limit: 1)).to eq([@fandom1])
    end

  end
end