# encoding: UTF-8
require 'spec_helper'

describe Tag do

  before(:each) do
    @tag = Tag.new
  end
  
  after(:each) do
    User.current_user = nil
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

      before(:each) do
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

    it "should be true for a tag with a Fandom parent" do
      tag_character = Factory.create(:character, :canonical => false)
      tag_fandom = Factory.create(:fandom, :canonical => true)
      tag_character.parents = [tag_fandom]
      tag_character.save

      tag_character.unwrangled?.should be_true
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

    it "should be true for a tag used on a bookmark" do
      tag = Factory.create(:unsorted_tag)
      tag.can_change_type?.should be_true
      
      # TODO: use factories when they stop giving validation errors and stack too deep errors
      creator = User.new(:terms_of_service => '1', :age_over_13 => '1')
      creator.login = "Creator"; creator.email = "creator@muse.net"
      creator.save
      bookmarker = User.new(:terms_of_service => '1', :age_over_13 => '1')
      bookmarker.login = "Bookmarker"; bookmarker.email = "bookmarker@avidfan.net"
      bookmarker.save
      chapter = Chapter.new(:content => "Whatever 10 characters", :authors => [creator.pseuds.first])
      work = Work.new(:title => "Work", :fandom_string => "Whatever", :authors => [creator.pseuds.first], :chapters => [chapter])
      work.posted = true
      work.save

      bookmark = Bookmark.create(:bookmarkable_type => "Work", :bookmarkable_id => work.id, :pseud_id => bookmarker.pseuds.first.id, :tag_string => tag.name)
      bookmark.tags.should include(tag)
      tag.can_change_type?.should be_true
    end

    it "should be true for a tag used on an external work" do
      external_work = Factory.create(:external_work, :character_string => "Jane Smith")
      tag = Tag.find_by_name("Jane Smith")

      tag.can_change_type?.should be_true
    end
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

    context "when the Character had a Fandom attached" do
      before do
        @unsorted_tag = Factory.create(:character, :canonical => false)
        fandom_tag = Factory.create(:fandom, :canonical => true)
        @unsorted_tag.parents = [fandom_tag]
        @unsorted_tag.save
      end

      it "should drop the Fandom when changed to UnsortedTag" do
        @unsorted_tag.type = "UnsortedTag"
        @unsorted_tag.save
        @unsorted_tag = Tag.find(@unsorted_tag.id)

        @unsorted_tag.should be_a(UnsortedTag)
        @unsorted_tag.parents.should be_empty
      end

      it "should drop the Fandom and add to Uncategorized when changed to Fandom" do
        @unsorted_tag.type = "Fandom"
        @unsorted_tag.save
        @unsorted_tag = Tag.find(@unsorted_tag.id)

        @unsorted_tag.should be_a(Fandom)
        @unsorted_tag.parents.should eq([Media.uncategorized])
      end
    end
  end

  describe "find_or_create_by_name" do
    it "should sort unsorted tags that get used on works" do
      tag = Factory.create(:unsorted_tag)
      work = Factory.create(:work, :character_string => tag.name)

      tag = Tag.find(tag.id)
      tag.should be_a(Character)
    end

    it "should sort unsorted tags that get used on external works" do
      tag = Factory.create(:unsorted_tag)
      external_work = Factory.create(:external_work, :character_string => tag.name)

      tag = Tag.find(tag.id)
      tag.should be_a(Character)
    end
  end
end
