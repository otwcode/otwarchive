require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < ActiveSupport::TestCase

  context "a category Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Category", Category::NAME
    end
    should "have a required tags" do
      assert_equal ['Gen', 'Het', 'Slash', 'Femslash', 'Multi', 'Other'].sort, Category.all.map(&:name).sort
    end
  end
    
end
