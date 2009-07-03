require File.dirname(__FILE__) + '/../test_helper'

class FreeformTest < ActiveSupport::TestCase

  context "a freeform Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.FREEFORM_CATEGORY_NAME, Freeform::NAME
    end
  end

  context "tags for tag cloud" do
    setup do
      @tag = create_character
      @tag.add_fandom(Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME))
    end
    should "not include other kinds of tags" do
       assert_does_not_contain(Tag.for_tag_cloud, @tag)
    end
  end

  context "tags without a fandom" do
    setup { @tag = create_freeform }
    should "not be included in the cloud" do
       assert_does_not_contain(Tag.for_tag_cloud, @tag)
    end
  end
  context "tags whose fandom is No Fandom" do
    setup do
      @tag = create_freeform
      @tag.add_fandom(Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME))
    end
    should "not be included in the cloud unless they are canonical" do
       assert_does_not_contain(Tag.for_tag_cloud, @tag)
    end
    context "which have been made canonical" do
      setup do
        @tag.update_attribute(:canonical, true)
      end
      should "be included in the cloud" do
        assert_contains(Tag.for_tag_cloud, @tag)
      end
    end
  end
  context "tags with a work which is not visible" do
    setup do
      @tag = create_freeform
      @work = create_work(:restricted => true)
      @work.update_attribute(:posted, true)
      @work.tags << @tag
    end
    should_eventually "not be included in the cloud" do
       assert_does_not_contain(Tag.for_tag_cloud, @tag)
    end
  end
  context "a canonical freeform" do
    setup do
      @freeform = create_freeform
      @freeform.wrangle_canonical
    end
    context "with a synonym" do
      setup do
        @freeform2 = create_freeform
        @freeform.add_synonym(@freeform2)
      end
      should "be listed in its mergers" do
        assert_equal [@freeform2], @freeform.mergers
      end
      context "which is removed" do
        setup do
          @freeform.remove_synonym(@freeform2)
        end
        should "not be listed in its mergers" do
          assert_equal [], @freeform.mergers
        end
      end
    end
    context "using update to add synonyms" do
      setup do
        @freeform2 = create_freeform
        @freeform.update_synonyms([@freeform2.name])
        @freeform.reload
      end
      should "be listed in its mergers" do
        assert_equal [@freeform2], @freeform.mergers
      end
      context "which is removed" do
        setup do
          @freeform.update_synonyms([""])
          @freeform.reload
        end
        should "not be listed in its mergers" do
          assert_equal [], @freeform.mergers
        end
      end
    end
    context "with a tag of a different class" do
      setup do
        @character = create_character
        @freeform.add_synonym(@character)
      end
      should "should not be able to be merged" do
        assert_equal [], @freeform.mergers
      end
    end
    context "which is wrangled by an admin" do
      setup do
        @freeform.update_type("Character", true)
      end
      should "be updated" do
        assert_equal 'Character', @freeform[:type]
      end
    end
    context "which is not wrangled by an admin" do
      setup do
        @freeform.update_type("Ambiguity", false)
      end
      should "be updated to an Ambiguity" do
        assert_equal 'Ambiguity', @freeform[:type]
      end
    end
    context "which is not wrangled by an admin or an Ambiguity" do
      setup do
        @freeform.update_type("Character", false)
      end
      should "not be updated to a Character" do
        assert_equal 'Freeform', @freeform[:type]
      end
    end
  end

end
