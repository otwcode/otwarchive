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
        @pairing.wrangle_canonical
      end
      context "which uses update on names" do
        setup do
          @character = create_character(:canonical => true)
          @character2 = create_character(:canonical => true)
          @pairing.update_characters([@character.name, @character2.name])
        end
        should "have both characters as a parents" do
          assert_equal [@character, @character2].sort, @pairing.parents.sort
        end
        context "removing one" do
          setup do
            @pairing.update_characters([@character.name])
          end
          should "have on character as parent" do
            assert_equal [@character].sort, @pairing.parents
          end
          should "mark the pairing as having characters" do
            assert @pairing.has_characters
          end
        end
        context "removing both" do
          setup do
            @pairing.update_characters([""])
          end
          should "have no characters as parent" do
            assert_equal [], @pairing.parents
          end
          should "mark the pairing as not having characters" do
            assert !@pairing.has_characters
          end
        end
      end
      context "which gets a character added" do
        setup do
          @character = create_character(:canonical => true)
          @pairing.add_character(@character)
        end
        should "have the character as a parent" do
          assert @pairing.parents.include?(@character)
        end
        should "mark the pairing as having characters" do
          assert @pairing.has_characters
        end
        context "which is later removed" do
          setup do
            @pairing.remove_character(@character)
          end
          should "not have the character as a parent" do
            assert !@pairing.parents.include?(@character)
          end
          should "mark the pairing as not having characters" do
            assert !@pairing.has_characters
          end
        end
        context "which gets a second character added" do
          setup do
            @character2 = create_character(:canonical => true)
            @pairing.add_character(@character2)
          end
          should "have both characters as a parents" do
            assert_equal [@character, @character2].sort, @pairing.parents.sort
          end
          should "mark the pairing as having characters" do
            assert @pairing.has_characters
          end
          context "when one is removed" do
            setup do
              @pairing.remove_character(@character)
            end
            should "still have the second character as a parent" do
              assert !@pairing.parents.include?(@character)
              assert @pairing.parents.include?(@character2)
            end
            should "still mark the pairing as having characters" do
              assert @pairing.has_characters
            end
          end
        end
      end
    end
  end


end
