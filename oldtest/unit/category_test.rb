require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  context "a category Tag" do
    setup do
      Category.create_canonical(ArchiveConfig.CATEGORY_HET_TAG_NAME)
      Category.create_canonical(ArchiveConfig.CATEGORY_SLASH_TAG_NAME)
      Category.create_canonical(ArchiveConfig.CATEGORY_FEMSLASH_TAG_NAME)
      Category.create_canonical(ArchiveConfig.CATEGORY_GEN_TAG_NAME)
      Category.create_canonical(ArchiveConfig.CATEGORY_MULTI_TAG_NAME)
      Category.create_canonical(ArchiveConfig.CATEGORY_OTHER_TAG_NAME)
    end
    should "have a display name" do
      assert_equal ArchiveConfig.CATEGORY_CATEGORY_NAME, Category::NAME
    end
    should "have required tags" do
      assert_same_elements [ArchiveConfig.CATEGORY_GEN_TAG_NAME,  ArchiveConfig.CATEGORY_HET_TAG_NAME,  ArchiveConfig.CATEGORY_SLASH_TAG_NAME,  ArchiveConfig.CATEGORY_FEMSLASH_TAG_NAME,  ArchiveConfig.CATEGORY_MULTI_TAG_NAME,  ArchiveConfig.CATEGORY_OTHER_TAG_NAME], Category.all.map(&:name)
    end
  end

end
