require 'test_helper'

class FreeformTest < ActiveSupport::TestCase

  context "a freeform Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.FREEFORM_CATEGORY_NAME, Freeform::NAME
    end
  end

  context "tags for tag cloud" do
    setup do
      @tag = create_character
      @no_fandom = Fandom.find_or_create_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
      @tag.add_association(@no_fandom)
    end
    should "not include other kinds of tags" do
       assert_does_not_contain(Freeform.for_tag_cloud_popular, @tag)
    end
  end

  context "tags without a fandom" do
    setup { @tag = create_freeform }
    should "not be included in the cloud" do
       assert_does_not_contain(Freeform.for_tag_cloud_popular, @tag)
    end
  end
  context "tags whose fandom is No Fandom" do
    setup do
      @tag = create_freeform
      @no_fandom = Fandom.find_or_create_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
      @tag.add_association(@no_fandom)
    end   
    context "with at least one visible work" do
      setup do
        @work = create_work(:posted => true, :freeform_string => @tag.name)
      end
      should "not be included in the cloud unless they are canonical" do
         assert_does_not_contain(Freeform.for_tag_cloud_popular, @tag)
      end
      context "which have been made canonical" do
        setup do
          @tag.update_attributes(:canonical => true)
       end
        should "be included in the cloud" do
          assert_contains(Freeform.for_tag_cloud_popular, @tag)
        end
      end
      context "whose work is no longer visible" do
        setup do
          @work.update_attribute(:restricted, true)
        end
        should "not be included in the cloud" do
          assert_does_not_contain(Freeform.for_tag_cloud_popular, @tag)
        end        
      end
    end
  end
  context "a canonical freeform" do
    setup do
      @freeform = create_freeform
      @freeform.update_attributes(:canonical => true)
    end
    context "with a synonym" do
      setup do
        @freeform2 = create_freeform
        @freeform2.update_attributes(:merger_id => @freeform.id)
      end
      should "be listed in its mergers" do
        assert_equal [@freeform2], @freeform.mergers
      end
      context "which is removed" do
        setup do
          @freeform2.update_attributes(:merger_id => nil)
       end
        should "not be listed in its mergers" do
          assert_equal [], @freeform.mergers
        end
      end
    end
    context "with a tag of a different class" do
      setup do
        @character = create_character
        @freeform.update_attributes(:merger_id => @character.id)
      end
      should "should not be able to be merged" do
        assert_equal [], @freeform.mergers
      end
    end
  end
end