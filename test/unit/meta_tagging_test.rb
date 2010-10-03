require 'test_helper'

class MetaTaggingTest < ActiveSupport::TestCase

  context "a meta tagging" do
    setup do
      @meta_tag = create_freeform(:canonical => true)
      @sub_tag = create_freeform(:canonical => true)
      @sub_tag.meta_tags << @meta_tag
      @character = create_character(:canonical => true)
    end
    should_belong_to :meta_tag, :sub_tag
    should_validate_presence_of :meta_tag, :sub_tag
    
    should "not allow a duplicate to be created" do
      assert_raises(ActiveRecord::RecordInvalid) { @sub_tag.meta_tags << @meta_tag }      
    end
    should "not exist between two tags of different types" do
      assert_raises(ActiveRecord::RecordInvalid) { @sub_tag.meta_tags << @character }      
    end    
    should "be direct" do
      assert_contains @sub_tag.direct_meta_tags, @meta_tag
      assert_contains @meta_tag.direct_sub_tags, @sub_tag
    end
    context "whose sub tag is used on a work" do
      setup do
        @work = create_work(:freeform_string => @sub_tag.name)
      end
      should "link the meta tag to the work as a filter" do
        assert_contains @work.filters, @meta_tag
      end
      context "when the sub tag is removed from the work" do
        setup do
          @work.freeforms = []
        end
        should "remove the meta tag from its filters" do
          assert_does_not_contain @work.filters, @meta_tag          
        end
      end            
    end
    context "whose meta tag has meta tags" do
      setup do
        @sub_sub_tag = create_freeform(:canonical => true)
        @sub_sub_tag.meta_tags << @sub_tag
      end
      should "inherit parent meta taggings" do
        assert_contains @sub_sub_tag.meta_tags, @meta_tag
      end
      should "not be marked direct if it's inherited" do
        assert_equal @sub_sub_tag.direct_meta_tags, [@sub_tag]
      end
      context "when the direct meta tag is removed" do
        setup do
          @sub_sub_tag.meta_tags.delete(@sub_tag)
        end
        should "also have its inherited meta tags removed" do
          assert_equal @sub_sub_tag.meta_tags, []
        end
      end
    end
  end
end