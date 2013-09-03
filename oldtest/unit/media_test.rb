require 'test_helper'

class MediaTest < ActiveSupport::TestCase

  context "a media Tag" do
    setup do
      Media.create_canonical(ArchiveConfig.MEDIA_UNCATEGORIZED_NAME)
      Media.create_canonical(ArchiveConfig.MEDIA_NO_TAG_NAME)
    end
    should "have a display name" do
      assert_equal ArchiveConfig.MEDIA_CATEGORY_NAME, Media::NAME
    end
    should "have required tags" do
      assert Tag.find_by_name(ArchiveConfig.MEDIA_UNCATEGORIZED_NAME).is_a?(Media)
      assert Tag.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME).is_a?(Media)
    end
  end

end
