require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  context "a relationship Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.RELATIONSHIP_CATEGORY_NAME, Relationship::NAME
    end
    setup do
      @relationship = create_relationship
    end
    context "which is canonical" do
      setup do
        @relationship.update_attribute(:canonical, true)
      end
      context "which gets a character added" do
        setup do
          @character = create_character(:canonical => true)
          @relationship.add_association(@character)
        end
        should "have the character as a parent" do
          assert_contains(@relationship.parents, @character)
        end
        context "which is later removed" do
          setup do
            @relationship.remove_association(@character)
          end
          should "not have the character as a parent" do
            assert_does_not_contain(@relationship.parents, @character)
          end
        end
        context "which gets a second character added" do
          setup do
            @character2 = create_character(:canonical => true)
            @relationship.add_association(@character2)
          end
          should "have both characters as a parents" do
            assert_same_elements [@character, @character2], @relationship.parents
          end
          context "when one is removed" do
            setup do
              @relationship.remove_association(@character)
            end
            should "still have the second character as a parent" do
              assert_does_not_contain(@relationship.parents, @character)
              assert_contains(@relationship.parents, @character2)
            end
          end
        end
      end
    end
  end


end
