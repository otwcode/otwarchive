require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    create_tag
  end

  context "a Tag" do
    should_have_many :common_taggings, :taggings
    should_have_many :works, :bookmarks, :external_works
    should_have_many :parents, :ambiguities, :filtered_works
    should_belong_to :merger, :fandom, :media
    should_require_attributes :name
    should_ensure_length_in_range :name, (1..ArchiveConfig.TAG_MAX), :long_message => /too long/, :short_message => /blank/
    should_allow_values_for :name, '"./?~!@#$%^&()_-+=', "1234567890", "spaces are not tag separators"
    should_not_allow_values_for :name, "commas, aren't allowed", :message => /can only/
    should_not_allow_values_for :name, "asterisks* aren't allowed", :message => /can only/
    should_not_allow_values_for :name, "angle brackets < aren't allowed", :message => /can only/
    should_not_allow_values_for :name, "angle brackets > aren't allowed", :message => /can only/

    should_allow_values_for :adult, true, false
    should_allow_values_for :canonical, true, false

    context "with whitespace" do
      setup do
        @tag = create_tag(:name => "   whitespace'll   (be    stripped)    ")
      end
      should "be stripped" do
        assert_equal "whitespace'll (be stripped)", @tag.name
      end
    end
  end


  context "tags on find_or_create_by_name" do
    setup do
      @string = "This tag should not yet exist"
      @tag = Character.find_or_create_by_name(@string)
      assert @tag2 = Fandom.find_or_create_by_name(@string)
    end
    should "be created" do
      assert @tag.is_a?(Character)
    end
    should "be found if it's the same class" do
      assert_equal @tag, Character.find_or_create_by_name(@tag.name)
    end
    should "be created with suffix if they're a different class" do
      assert_not_equal @tag, @tag2
      assert_equal @string + " - Fandom", @tag2.name
    end
  end

  context "tags with different capitalization" do
    setup do
      @tag1 = Tag.find_or_create_by_name("A tag")
      @tag2 = Tag.find_or_create_by_name("b tag")
      @tag3 = Tag.find_or_create_by_name("C tag")
    end
    should "sort case insensitive" do
      assert_equal [@tag1, @tag2, @tag3], [@tag3, @tag1, @tag2].sort
    end
  end

  context "a regular tag" do
    setup do
      @tag = create_freeform
      @child = create_freeform
      @work = create_work
      @work.tags << [Fandom.first, Warning.first, Category.first, Rating.first]
      @work.update_attribute(:posted, true)
      @work.freeform_string = @tag.name
      @work.reload
    end
    should "not originally be included in common taggings" do
      assert !@work.common_tags.include?(@tag)
    end
    context "and another tag with a fandom" do
      setup do
        @tag2 = create_freeform
        @fandom = create_fandom(:canonical => true)
        @tag2.add_fandom(@fandom)
        @tag.wrangle_merger(@tag2)
        @tag.wrangle_parent(@tag2)
      end
      should "not merge if not canonical" do
        assert_not_equal @tag.merger, @tag2
      end
      should "not be a parent if not canonical" do
        assert !@tag.parents.include?(@tag2)
      end
      context "which is canonical and merged" do
        setup do
          @fandom2 = create_fandom(:canonical => true)
          @tag.add_fandom(@fandom2)
          assert_equal @tag.fandom_id, @fandom2.id
          @tag2.wrangle_canonical
          @tag.wrangle_merger(@tag2)
          @tag2.reload
          @tag.reload
        end
        should "be merged" do
          assert_equal @tag.merger, @tag2
        end
        should "get the merger's fandom" do
          assert @tag.fandoms.include?(@fandom)
        end
        should "get the merger's fandom_id" do
          assert_equal @tag2.fandom_id, @tag.fandom_id
        end
        should "have the merger in the tag's work's common tags" do
          assert @work.common_tags.include?(@tag2)
        end
        should "have the merger's fandom in the tag's work's common tags" do
          assert @work.common_tags.include?(@fandom)
        end
        should "be listed in the merger's family" do
          assert @tag2.family.include?(@tag)
        end
        should "have the merger in its family" do
          assert @tag.family.include?(@tag2)
        end
      end
      context "which is canonical and made a parent" do
        setup do
          @tag2.wrangle_canonical
          @tag.wrangle_parent(@tag2)
        end
        should "be a parent" do
          assert @tag.parents.include?(@tag2)
        end
        should "get the parent's fandom" do
          assert @tag.fandoms.include?(@fandom)
        end
        should "have the parent in the tag's work's common tags" do
          assert @work.common_tags.include?(@tag2)
        end
        should "have the parent's fandom in the tag's work's common tags" do
          assert @work.common_tags.include?(@fandom)
        end
        should "be listed in the parents children" do
          assert @tag2.children.include?(@tag)
        end
        should "be listed in the parents family" do
          assert @tag2.family.include?(@tag)
        end
        should "have the parent in its family" do
          assert @tag.family.include?(@tag2)
        end
      end
    end
    context "and another tag of a different category" do
      setup do
        @tag2 = create_pairing
        @tag2.wrangle_canonical
        @tag.wrangle_merger(@tag2)
      end
      should "not be merged" do
        assert_not_equal @tag2.merger, @tag
      end
    end
    context "when made canonical" do
      setup do
        @tag.wrangle_canonical
      end
      should "be added to common taggings" do
        assert @work.common_tags.include?(@tag)
      end
      context "when made non-canonical" do
        setup do
          @tag.wrangle_not_canonical
        end
        should "be removed from common taggings" do
          assert !@work.common_tags.include?(@tag)
        end
      end
    end
  end

  context "a wrangled tag" do
    setup do
      @tag = create_character
      @merger = create_character(:canonical => true)
      @fandom = create_fandom(:canonical => true)
      @character = create_character(:canonical => true)
      @tag.wrangle_merger(@merger)
      @tag.add_fandom(@fandom)
    end
    should "have parents in common_tags" do
      assert @tag.common_tags_to_add.include?(@fandom)
    end
    should "have merger in common_tags" do
      assert @tag.common_tags_to_add.include?(@merger)
    end
    should "have self in common_tags if canonical" do
      assert @character.common_tags_to_add.include?(@character)
    end
    should "not have self in common_tags if not canonical" do
      assert !@tag.common_tags_to_add.include?(@tag)
    end
  end

end
