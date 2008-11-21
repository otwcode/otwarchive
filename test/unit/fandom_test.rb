require File.dirname(__FILE__) + '/../test_helper'

class FandomTest < ActiveSupport::TestCase

  context "a fandom Tag" do
    should_require_attributes :name
    should "have a display name" do
      assert_equal ArchiveConfig.FANDOM_CATEGORY_NAME, Fandom::NAME
    end
    should "have a default tag" do
      assert_equal ArchiveConfig.FANDOM_NO_TAG_NAME, Fandom.first.name
    end
  end
  
  
 
end
