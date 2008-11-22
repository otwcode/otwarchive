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
    context "with children" do
      setup do 
        @fandom = create_fandom(:canonical => true)
        @fandom2 = create_fandom(:canonical => true)
        @character = create_character(:fandom_id => @fandom.id)
        @character2 = create_character(:fandom_id => @fandom2.id)
        @character2.wrangle_parent(@fandom)
      end
      should "have the right children" do
        assert_equal [@character, @character2].sort, @fandom.children.sort
      end
      should "have unwrangled" do
        assert_equal [@character, @character2].sort, @fandom.children.select(&:unwrangled).group_by(&:type)['Character'].sort
      end
      context "on merger" do
        setup do 
          @fandom.wrangle_merger(@fandom2)
          @character.reload
        end
        should "wrangle their fandoms" do
         assert_equal @fandom2, @character.fandom
        end
      end
    end
  end
  
  
 
end
