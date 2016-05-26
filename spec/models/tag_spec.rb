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
    expect(@tag.save).not_to be_truthy

    @tag.name = "something or other"
    expect(@tag.save).to be_truthy
  end

  it "should not be valid if too long" do
    @tag.name = "a" * 101
    expect(@tag.save).not_to be_truthy
    expect(@tag.errors[:name].join).to match(/too long/)
  end

  it "should not be valid with disallowed characters" do
    @tag.name = "bad<tag"
    expect(@tag.save).to be_falsey
    expect(@tag.errors[:name].join).to match(/restricted characters/)
  end

  context "unwrangleable" do
    it "should not be valid as canonical and unwrangleable" do
      tag = Freeform.create(name: "wrangled", canonical: true)

      tag.unwrangleable = true
      expect(tag).not_to be_valid
    end

    it "should not be valid as unsorted and unwrangleable" do
      tag = FactoryGirl.create(:unsorted_tag)

      tag.unwrangleable = true
      expect(tag).not_to be_valid
    end
  end

  context "when checking for synonym/name change" do

    context "when logged in as a regular user" do

      before(:each) do
        User.current_user = FactoryGirl.create(:user)
      end

      it "should ignore capitalisation" do
        @tag.name = "yuletide"
        @tag.save

        @tag.name = "Yuletide"
        @tag.check_synonym
        expect(@tag.errors).to be_empty
        expect(@tag.save).to be_truthy
      end

      it "should ignore accented characters" do
        @tag.name = "Amelie"
        @tag.save

        @tag.name = "Amélie"
        @tag.check_synonym
        expect(@tag.errors).to be_empty
        expect(@tag.save).to be_truthy
      end

      it "should be careful with the ß" do
        @tag.name = "Wei Kreuz"
        @tag.save

        @tag.name = "Weiß Kreuz"
        @tag.check_synonym
        expect(@tag.errors).to be_empty
        expect(@tag.save).to be_truthy
      end

      it "should not ignore punctuation" do
        @tag.name = "Snatch."
        @tag.save

        @tag.name = "Snatch"
        @tag.check_synonym
        expect(@tag.errors).not_to be_empty
        expect(@tag.save).to be_falsey
      end

      it "should not ignore whitespace" do
        @tag.name = "JohnSheppard"
        @tag.save

        @tag.name = "John Sheppard"
        @tag.check_synonym
        expect(@tag.errors).not_to be_empty
        expect(@tag.save).to be_falsey
      end

      it 'autocomplete should work' do
        tag_character = FactoryGirl.create(:character, canonical: true, name: 'kirk')
        tag_fandom = FactoryGirl.create(:fandom, name: 'Star Trek', canonical: true)
        tag_fandom.add_to_autocomplete
        results=Tag.autocomplete_fandom_lookup(term: 'ki', fandom: 'Star Trek' )
        expect(results.include?("#{tag_character.id}: #{tag_character.name}")).to be_truthy
        expect(results.include?("brave_sire_robin")).to be_falsey
      end

      it 'old tag maker still works' do
        tag_adult=Rating.create_canonical('adult', true)
        tag_normal=Warning.create_canonical('other')
        expect(tag_adult.name).to eq('adult')
        expect(tag_normal.name).to eq('other')
        expect(tag_adult.adult).to be_truthy
        expect(tag_normal.adult).to be_falsey
      end
    end

    context "when logged in as an admin" do
      before do
        User.current_user = FactoryGirl.create(:admin)
      end

      it "should allow any change" do
        @tag.name = "yuletide.ssé"
        @tag.save

        @tag.name = "Yuletide ße something"
        @tag.check_synonym
        expect(@tag.errors).to be_empty
        expect(@tag.save).to be_truthy
      end
    end
  end

  describe "unwrangled?" do
    it "should be false for a canonical" do
      tag = Freeform.create(name: "canonical", canonical: true)
      expect(tag.unwrangled?).to be_falsey
    end

    it "should be false for an unwrangleable" do
      tag = Tag.create(name: "unwrangleable", unwrangleable: true)
      expect(tag.unwrangled?).to be_falsey
    end

    it "should be false for a synonym" do
      tag = Tag.create(name: "synonym")
      tag_merger = Tag.create(name: "merger")
      tag.merger = tag_merger
      tag.save
      expect(tag.unwrangled?).to be_falsey
    end

    it "should be false for a merger tag" do
      tag = Tag.create(name: "merger")
      tag_syn = Tag.create(name: "synonym")
      tag_syn.merger = tag
      tag_syn.save
      expect(tag.unwrangled?).to be_falsey
    end

    it "should be true for a tag with a Fandom parent" do
      tag_character = FactoryGirl.create(:character, canonical: false)
      tag_fandom = FactoryGirl.create(:fandom, canonical: true)
      tag_character.parents = [tag_fandom]
      tag_character.save

      expect(tag_character.unwrangled?).to be_truthy
    end
  end

  describe "can_change_type?" do
    it "should be false for a wrangled tag" do
      tag = Freeform.create(name: "wrangled", canonical: true)
      expect(tag.can_change_type?).to be_falsey
    end

    it "should be false for a tag used on a draft" do
      tag = Fandom.create(name: "Fandom")
      expect(tag.can_change_type?).to be_truthy

      work = FactoryGirl.create(:work, fandom_string: tag.name)
      expect(tag.can_change_type?).to be_falsey
    end

    it "should be false for a tag used on a work" do
      tag = Fandom.create(name: "Fandom")
      expect(tag.can_change_type?).to be_truthy

      work = FactoryGirl.create(:work, fandom_string: tag.name)
      work.posted = true
      work.save
      expect(tag.can_change_type?).to be_falsey
    end

    it "should be false for a tag used in a tag set"

    it "should be true for a tag used on a bookmark" do
      tag = FactoryGirl.create(:unsorted_tag)
      expect(tag.can_change_type?).to be_truthy

      # TODO: use factories when they stop giving validation errors and stack too deep errors
      creator = User.new(terms_of_service: '1', age_over_13: '1')
      creator.login = "Creator"; creator.email = "creator@muse.net"
      creator.save
      bookmarker = User.new(terms_of_service: '1', age_over_13: '1')
      bookmarker.login = "Bookmarker"; bookmarker.email = "bookmarker@avidfan.net"
      bookmarker.save
      chapter = Chapter.new(content: "Whatever 10 characters", authors: [creator.pseuds.first])
      work = Work.new(title: "Work", fandom_string: "Whatever", authors: [creator.pseuds.first], chapters: [chapter])
      work.posted = true
      work.save

      bookmark = Bookmark.create(bookmarkable_type: "Work", bookmarkable_id: work.id, pseud_id: bookmarker.pseuds.first.id, tag_string: tag.name)
      expect(bookmark.tags).to include(tag)
      expect(tag.can_change_type?).to be_truthy
    end

    it "should be true for a tag used on an external work" do
      external_work = FactoryGirl.create(:external_work, character_string: "Jane Smith")
      tag = Tag.find_by_name("Jane Smith")

      expect(tag.can_change_type?).to be_truthy
    end
  end

  describe "type changes" do
    context "from Unsorted to Fandom" do
      before do
        @fandom_tag = FactoryGirl.create(:unsorted_tag)
        @fandom_tag.type = "Fandom"
        @fandom_tag.save
        @fandom_tag = Tag.find(@fandom_tag.id)
      end

      it "should be a Fandom" do
        expect(@fandom_tag).to be_a(Fandom)
      end

      it "should have the Uncategorized Fandoms Media as a parent" do
        expect(@fandom_tag.parents).to eq([Media.uncategorized])
      end
    end

    context "from Unsorted to Character" do
      before do
        @character_tag = FactoryGirl.create(:unsorted_tag)
        @character_tag.type = "Character"
        @character_tag.save
        @character_tag = Tag.find(@character_tag.id)
      end

      it "should be a Character" do
        expect(@character_tag).to be_a(Character)
      end

      it "should not have any parents" do
        expect(@character_tag.parents).to be_empty
      end
    end

    context "from Fandom to Unsorted" do
      before do
        @unsorted_tag = FactoryGirl.create(:fandom, canonical: false)
        @unsorted_tag.type = "UnsortedTag"
        @unsorted_tag.save
        @unsorted_tag = Tag.find(@unsorted_tag.id)
      end

      it "should be an UnsortedTag" do
        expect(@unsorted_tag).to be_a(UnsortedTag)
      end

      it "should not have any parents" do
        expect(@unsorted_tag.parents).not_to eq([Media.uncategorized])
        expect(@unsorted_tag.parents).to be_empty
      end
    end

    context "from Fandom to Character" do
      before do
        @character_tag = FactoryGirl.create(:fandom, canonical: false)
        @character_tag.type = "Character"
        @character_tag.save
        @character_tag = Tag.find(@character_tag.id)
      end

      it "should be a Character" do
        expect(@character_tag).to be_a(Character)
      end

      it "should not have any parents" do
        expect(@character_tag.parents).not_to eq([Media.uncategorized])
        expect(@character_tag.parents).to be_empty
      end
    end

    context "from Character to Unsorted" do
      before do
        @unsorted_tag = FactoryGirl.create(:character, canonical: false)
        @unsorted_tag.type = "UnsortedTag"
        @unsorted_tag.save
        @unsorted_tag = Tag.find(@unsorted_tag.id)
      end

      it "should be an UnsortedTag" do
        expect(@unsorted_tag).to be_a(UnsortedTag)
      end

      it "should not have any parents" do
        expect(@unsorted_tag.parents).to be_empty
      end
    end

    context "from Character to Fandom" do
      before do
        @fandom_tag = FactoryGirl.create(:character, canonical: false)
        @fandom_tag.type = "Fandom"
        @fandom_tag.save
        @fandom_tag = Tag.find(@fandom_tag.id)
      end

      it "should be a Fandom" do
        expect(@fandom_tag).to be_a(Fandom)
      end

      it "should have the Uncategorized Fandoms Media as a parent" do
        expect(@fandom_tag.parents).to eq([Media.uncategorized])
      end
    end

    context "when the Character had a Fandom attached" do
      before do
        @unsorted_tag = FactoryGirl.create(:character, canonical: false)
        fandom_tag = FactoryGirl.create(:fandom, canonical: true)
        @unsorted_tag.parents = [fandom_tag]
        @unsorted_tag.save
      end

      it "should drop the Fandom when changed to UnsortedTag" do
        @unsorted_tag.type = "UnsortedTag"
        @unsorted_tag.save
        @unsorted_tag = Tag.find(@unsorted_tag.id)

        expect(@unsorted_tag).to be_a(UnsortedTag)
        expect(@unsorted_tag.parents).to be_empty
      end

      it "should drop the Fandom and add to Uncategorized when changed to Fandom" do
        @unsorted_tag.type = "Fandom"
        @unsorted_tag.save
        @unsorted_tag = Tag.find(@unsorted_tag.id)

        expect(@unsorted_tag).to be_a(Fandom)
        expect(@unsorted_tag.parents).to eq([Media.uncategorized])
      end
    end
  end

  describe "find_or_create_by_name" do
    it "should sort unsorted tags that get used on works" do
      tag = FactoryGirl.create(:unsorted_tag)
      work = FactoryGirl.create(:work, character_string: tag.name)

      tag = Tag.find(tag.id)
      expect(tag).to be_a(Character)
    end

    it "should sort unsorted tags that get used on external works" do
      tag = FactoryGirl.create(:unsorted_tag)
      external_work = FactoryGirl.create(:external_work, character_string: tag.name)

      tag = Tag.find(tag.id)
      expect(tag).to be_a(Character)
    end
  end

  describe "multiple tags of the same type" do
    before do
      # set up three tags of the same type
      @canonical_tag = FactoryGirl.create(:fandom)
      @syn_tag = FactoryGirl.create(:fandom)
      @sub_tag = FactoryGirl.create(:fandom)
    end

    it "should let you make a tag the synonym of a canonical one" do
      @syn_tag.syn_string = @canonical_tag.name
      @syn_tag.save

      expect(@syn_tag.merger).to eq(@canonical_tag)
      @canonical_tag = Tag.find(@canonical_tag.id)
      expect(@canonical_tag.mergers).to eq([@syn_tag])
    end

    it "should let you make a canonical tag the subtag of another canonical one" do
      @sub_tag.meta_tag_string = @canonical_tag.name

      expect(@canonical_tag.sub_tags).to eq([@sub_tag])
      expect(@sub_tag.meta_tags).to eq([@canonical_tag])
    end

    describe "with a synonym and a subtag" do
      before do
        @syn_tag.syn_string = @canonical_tag.name
        @syn_tag.save
        @sub_tag.meta_tag_string = @canonical_tag.name
      end

      describe "and works under each" do
        before do
          # create works with all three tags
          @direct_work = FactoryGirl.create(:work, fandom_string: @canonical_tag.name)
          @syn_work = FactoryGirl.create(:work, fandom_string: @syn_tag.name)
          @sub_work = FactoryGirl.create(:work, fandom_string: @sub_tag.name)
        end

        xit "should find all works that would need to be reindexed" do
          # get all the work ids that it would queue
          expect(@syn_tag.all_filtered_work_ids).to eq([@syn_work.id])
          expect(@sub_tag.all_filtered_work_ids).to eq([@sub_work.id])
          expect(@canonical_tag.all_filtered_work_ids).to eq([@direct_work.id, @syn_work.id, @sub_work.id])

          # make sure the canonical tag continues to have the right ids even if set to non-canonical
          @canonical_tag.canonical = false
          expect(@canonical_tag.all_filtered_work_ids).to match_array([@direct_work.id, @syn_work.id, @sub_work.id])

        end
      end

      describe "and bookmarks under each" do
        before do
          # create bookmarks with all three tags
          @direct_bm = FactoryGirl.create(:bookmark, tag_string: @canonical_tag.name)
          @syn_bm = FactoryGirl.create(:bookmark, tag_string: @syn_tag.name)
          @sub_bm = FactoryGirl.create(:bookmark, tag_string: @sub_tag.name)
        end

        it "should find all bookmarks that would need to be reindexed" do
          expect(@syn_tag.all_bookmark_ids).to eq([@syn_bm.id])
          expect(@sub_tag.all_bookmark_ids).to eq([@sub_bm.id])
          expect(@canonical_tag.all_bookmark_ids).to  match_array([@direct_bm.id, @syn_bm.id, @sub_bm.id])
        end
      end
    end
  end

end
