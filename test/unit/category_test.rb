require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < ActiveSupport::TestCase

  context "a category Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.CATEGORY_CATEGORY_NAME, Category::NAME
    end
    should "have a required tags" do
      assert_equal [ArchiveConfig.CATEGORY_GEN_TAG_NAME,  ArchiveConfig.CATEGORY_HET_TAG_NAME,  ArchiveConfig.CATEGORY_SLASH_TAG_NAME,  ArchiveConfig.CATEGORY_FEMSLASH_TAG_NAME,  ArchiveConfig.CATEGORY_MULTI_TAG_NAME,  ArchiveConfig.CATEGORY_OTHER_TAG_NAME].sort, Category.all.map(&:name).sort
    end
  end
    
end
