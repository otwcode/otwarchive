require 'test_helper'

class CharacterTest < ActiveSupport::TestCase

  context "a character Tag" do
    setup do
      @character = create_character
      @fandom = create_fandom(:canonical => true)
      @character.add_association(@fandom)
    end
    should "have a display name" do
      assert_equal ArchiveConfig.CHARACTER_CATEGORY_NAME, Character::NAME
    end
    should "be able to add a fandom" do
      assert_contains @character.fandoms, @fandom
    end
    context "with an added fandom" do
      setup do
        @fandom2 = create_fandom(:canonical => true)
        @character.add_association(@fandom2)
      end
      should "have both fandoms" do
        assert_same_elements [@fandom, @fandom2], @character.fandoms
      end
    end
    context "which is canonical" do
      setup do
        @character.update_attributes(:canonical => true)
      end
      context "which gets a relationship added" do
        setup do
          @relationship = create_relationship
          @character.add_association(@relationship)
        end
        should "have the relationship as a child" do
          assert_contains(@character.children, @relationship)
        end
        context "which is later removed" do
          setup do
            @character.remove_association(@relationship)
          end
          should "not have the relationship as a child" do
            assert_does_not_contain(@character.children, @relationship)
          end
        end
      end
    end
  end
end