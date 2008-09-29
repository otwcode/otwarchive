require File.dirname(__FILE__) + '/../test_helper'

class TagCategoryTest < ActiveSupport::TestCase
  context "a Tag Category" do
    setup do
      @tag_category = create_tag_category
    end
    should_have_many :tags
    should_require_unique_attributes :name
    context "which has a tag" do
      setup do
        @tag = create_tag(:tag_category => @tag_category)
      end
      context "when the category is destroyed" do
        setup do
          @tag_category.destroy
          @tag.reload
        end
        should "set its previous tags back to no category" do
          assert_equal nil, @tag.tag_category
        end
      end
      context "which is canonical" do
        setup do
          @tag.update_attribute(:canonical, true)
        end
        should "find that tag in its official tags list" do
          assert TagCategory.official_tags(@tag_category.name).include?(@tag)
        end
      end
    end
  end
  context "the ambiguous tag category" do
    should "exist" do
      assert TagCategory.ambiguous_tag_category
    end
  end
  context "the default tag category" do
    should "exist" do
      assert TagCategory.default_tag_category
    end
  end
end
