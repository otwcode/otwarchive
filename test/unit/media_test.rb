require File.dirname(__FILE__) + '/../test_helper'

class MediaTest < ActiveSupport::TestCase

  context "a media Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags, :fandoms
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Media", Media::NAME
    end
  end
    
end
