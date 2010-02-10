require File.dirname(__FILE__) + '/../test_helper'

class PairingTest < ActiveSupport::TestCase

  context "a pairing Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.PAIRING_CATEGORY_NAME, Pairing::NAME
    end
    setup do
      @pairing = create_pairing
    end
    context "which is canonical" do
      setup do
        @pairing.update_attribute(:canonical, true)
      end
      context "which gets a character added" do
        setup do
          @character = create_character(:canonical => true)
          @pairing.add_association(@character)
        end
        should "have the character as a parent" do
          assert_contains(@pairing.parents, @character)
        end
        context "which is later removed" do
          setup do
            @pairing.remove_association(@character)
          end
          should "not have the character as a parent" do
            assert_does_not_contain(@pairing.parents, @character)
          end
        end
        context "which gets a second character added" do
          setup do
            @character2 = create_character(:canonical => true)
            @pairing.add_association(@character2)
          end
          should "have both characters as a parents" do
            assert_same_elements [@character, @character2], @pairing.parents
          end
          context "when one is removed" do
            setup do
              @pairing.remove_association(@character)
            end
            should "still have the second character as a parent" do
              assert_does_not_contain(@pairing.parents, @character)
              assert_contains(@pairing.parents, @character2)
            end
          end
        end
      end
    end
  end


end
