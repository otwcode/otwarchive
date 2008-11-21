require File.dirname(__FILE__) + '/../test_helper'

class CharacterTest < ActiveSupport::TestCase

  context "a character Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.CHARACTER_CATEGORY_NAME, Character::NAME
    end
  end
    
end
