require File.dirname(__FILE__) + '/../test_helper'

class MediaTest < ActiveSupport::TestCase

  context "a media Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.MEDIA_CATEGORY_NAME, Media::NAME
    end
  end

end
