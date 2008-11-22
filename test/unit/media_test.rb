require File.dirname(__FILE__) + '/../test_helper'

class MediaTest < ActiveSupport::TestCase

  context "a media Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.MEDIA_CATEGORY_NAME, Media::NAME
    end
    should "have a default tag" do
      assert_equal ArchiveConfig.MEDIA_NO_TAG_NAME, Media.first.name
    end
    context "with children" do
      setup do 
        @media = create_media(:canonical => true)
        @media2 = create_media(:canonical => true)
        @fandom = create_fandom(:media_id => @media.id)
        @fandom2 = create_fandom(:media_id => @media2.id)
        @fandom2.wrangle_parent(@media)
        @media.reload
      end
      should "have the right children" do
        assert_equal [@fandom, @fandom2].sort, @media.children.sort
      end
      context "on merger" do
        setup do 
          @media.wrangle_merger(@media2)
          @fandom.reload
        end
        should "wrangle their fandoms on merger" do
          assert_equal @media2, @fandom.media
        end
      end
    end
  end
    
end
