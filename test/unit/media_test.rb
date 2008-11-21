require File.dirname(__FILE__) + '/../test_helper'

class MediaTest < ActiveSupport::TestCase

  context "a media Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.MEDIA_CATEGORY_NAME, Media::NAME
    end
    should "have a default tag" do
      assert_equal ArchiveConfig.MEDIA_NO_TAG_NAME, Media.first.name
    end
  end
    
end
