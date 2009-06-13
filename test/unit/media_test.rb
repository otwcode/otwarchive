require File.dirname(__FILE__) + '/../test_helper'

class MediaTest < ActiveSupport::TestCase

  context "a media Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.MEDIA_CATEGORY_NAME, Media::NAME
    end
    should "have a no media tag" do
      assert Media.all.collect(&:name).include? ArchiveConfig.MEDIA_NO_TAG_NAME
    end
    should "have an uncategorized fandoms tag" do
      assert Media.all.collect(&:name).include? ArchiveConfig.MEDIA_UNCATEGORIZED_NAME
    end
  end

end
