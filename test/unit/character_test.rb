require File.dirname(__FILE__) + '/../test_helper'

class CharacterTest < ActiveSupport::TestCase

  context "a media Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags, :pairings
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Character", Character::NAME
    end
  end
    
  context "a new character on a new work" do
    setup do
      @work = create_work
      @work.character_string = "new character"
    end
    should "get the fandom of the work" do
      assert_equal @work.fandoms, [Character.find_by_name("new character").fandom]
    end
  end
  
end
