# encoding: UTF-8
require 'spec_helper'

describe Tag do

  before(:each) do
    @tag = Tag.new
  end

  it "should not be valid without a name" do
    @tag.save.should_not be_true

    @tag.name = "something or other"
    @tag.save.should be_true
  end

  it "should not be valid if too long" do
    @tag.name = "a" * 101
    @tag.save.should_not be_true
    @tag.errors[:name].join.should =~ /too long/
  end

  it "should not be valid with disallowed characters" do
    @tag.name = "bad<tag"
    @tag.save.should be_false
    @tag.errors[:name].join.should =~ /restricted characters/
  end

  context "when checking for synonym/name change" do

    context "when logged in as a regular user" do

      before do
        User.current_user = Factory.create(:user)
      end

      it "should ignore capitalisation" do
        @tag.name = "yuletide"
        @tag.save

        @tag.name = "Yuletide"
        @tag.check_synonym
        @tag.errors.should be_empty
        @tag.save.should be_true
      end

      it "should ignore accented characters" do
        @tag.name = "Amelie"
        @tag.save

        @tag.name = "Amélie"
        @tag.check_synonym
        @tag.errors.should be_empty
        @tag.save.should be_true
      end

      it "should be careful with the ß" do
        @tag.name = "Wei Kreuz"
        @tag.save

        @tag.name = "Weiß Kreuz"
        @tag.check_synonym
        @tag.errors.should be_empty
        @tag.save.should be_true
      end

      it "should not ignore punctuation" do
        @tag.name = "Snatch."
        @tag.save

        @tag.name = "Snatch"
        @tag.check_synonym
        @tag.errors.should_not be_empty
        @tag.save.should be_false
      end

      it "should not ignore whitespace" do
        @tag.name = "JohnSheppard"
        @tag.save

        @tag.name = "John Sheppard"
        @tag.check_synonym
        @tag.errors.should_not be_empty
        @tag.save.should be_false
      end
    end

    context "when logged in as an admin" do
      before do
        User.current_user = Factory.create(:admin)
      end

      it "should allow any change" do
        @tag.name = "yuletide.ssé"
        @tag.save

        @tag.name = "Yuletide ße something"
        @tag.check_synonym
        @tag.errors.should be_empty
        @tag.save.should be_true
      end
    end
  end

  describe "unwrangled?" do
    it "should be false for a canonical" do
      tag = Freeform.create(:name => "canonical", :canonical => true)
      tag.unwrangled?.should be_false
    end

    it "should be false for an unwrangleable" do
      tag = Tag.create(:name => "unwrangleable", :unwrangleable => true)
      tag.unwrangled?.should be_false
    end

    it "should be false for a synonym" do
      tag = Tag.create(:name => "synonym")
      tag_merger = Tag.create(:name => "merger")
      tag.merger = tag_merger
      tag.save
      tag.unwrangled?.should be_false
    end

    it "should be false for a merger tag" do
      tag = Tag.create(:name => "merger")
      tag_syn = Tag.create(:name => "synonym")
      tag_syn.merger = tag
      tag_syn.save
      tag.unwrangled?.should be_false
    end
  end

  describe "can_change_type?" do
    it "should be false for a wrangled tag" do
      tag = Freeform.create(:name => "wrangled", :canonical => true)
      tag.can_change_type?.should be_false
    end

    it "should be false for a tag used on a draft" do
      tag = Fandom.create(:name => "Fandom")
      tag.can_change_type?.should be_true

      work = Factory.create(:work, :fandom_string => tag.name)
      tag.can_change_type?.should be_false      
    end

    it "should be false for a tag used on a work" do
      tag = Fandom.create(:name => "Fandom")
      tag.can_change_type?.should be_true

      work = Factory.create(:work, :fandom_string => tag.name)
      work.posted = true
      work.save
      tag.can_change_type?.should be_false
    end

    it "should be false for a tag used in a tag set"
  end

  describe "type changes" do
    context "from Unsorted to Fandom" do
      before do
        @fandom_tag = Factory.create(:unsorted_tag)
        @fandom_tag.type = "Fandom"
        @fandom_tag.save
        @fandom_tag = Tag.find(@fandom_tag.id)
      end

      it "should be a Fandom" do
        @fandom_tag.should be_a(Fandom)
      end

      it "should have the Uncategorized Fandoms Media as a parent" do
        @fandom_tag.parents.should eq([Media.uncategorized])
      end
    end

    context "from Unsorted to Character" do
      before do
        @character_tag = Factory.create(:unsorted_tag)
        @character_tag.type = "Character"
        @character_tag.save
        @character_tag = Tag.find(@character_tag.id)
      end

      it "should be a Character" do
        @character_tag.should be_a(Character)
      end

      it "should not have any parents" do
        @character_tag.parents.should be_empty
      end
    end

    context "from Fandom to Unsorted" do
      before do
        @unsorted_tag = Factory.create(:fandom, :canonical => false)
        @unsorted_tag.type = "UnsortedTag"
        @unsorted_tag.save
        @unsorted_tag = Tag.find(@unsorted_tag.id)
      end

      it "should be an UnsortedTag" do
        @unsorted_tag.should be_a(UnsortedTag)
      end

      it "should not have any parents" do
        @unsorted_tag.parents.should_not eq([Media.uncategorized])
        @unsorted_tag.parents.should be_empty
      end
    end

    context "from Fandom to Character" do
      before do
        @character_tag = Factory.create(:fandom, :canonical => false)
        @character_tag.type = "Character"
        @character_tag.save
        @character_tag = Tag.find(@character_tag.id)
      end

      it "should be a Character" do
        @character_tag.should be_a(Character)
      end

      it "should not have any parents" do
        @character_tag.parents.should_not eq([Media.uncategorized])
        @character_tag.parents.should be_empty
      end
    end

    context "from Character to Unsorted" do
      before do
        @unsorted_tag = Factory.create(:character, :canonical => false)
        @unsorted_tag.type = "UnsortedTag"
        @unsorted_tag.save
        @unsorted_tag = Tag.find(@unsorted_tag.id)
      end

      it "should be an UnsortedTag" do
        @unsorted_tag.should be_a(UnsortedTag)
      end

      it "should not have any parents" do
        @unsorted_tag.parents.should be_empty
      end
    end

    context "from Character to Fandom" do
      before do
        @fandom_tag = Factory.create(:character, :canonical => false)
        @fandom_tag.type = "Fandom"
        @fandom_tag.save
        @fandom_tag = Tag.find(@fandom_tag.id)
      end

      it "should be a Fandom" do
        @fandom_tag.should be_a(Fandom)
      end

      it "should have the Uncategorized Fandoms Media as a parent" do
        @fandom_tag.parents.should eq([Media.uncategorized])
      end
    end
  end
end
