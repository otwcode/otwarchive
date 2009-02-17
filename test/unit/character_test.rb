require File.dirname(__FILE__) + '/../test_helper'

class CharacterTest < ActiveSupport::TestCase

  context "a character Tag" do
    setup do
      @character = create_character
      @fandom = create_fandom(:canonical => true)
      @character.add_parent_by_id(@fandom.id)
    end
    should "have a display name" do
      assert_equal ArchiveConfig.CHARACTER_CATEGORY_NAME, Character::NAME
    end
    should "be able to add a media as a parent by id" do
      assert_equal @fandom, @character.fandom
    end
    context "with an added fandom" do
      setup do
        @fandom2 = create_fandom(:canonical => true)
        @character.add_fandom(@fandom2)
      end
      should "have both fandoms" do
        assert_equal [@fandom, @fandom2].sort, @character.fandoms.sort
      end
      context "with one fandom removed" do
        setup do
          @character.remove_fandom(@fandom)
          @character.reload
        end
        should "still have the other as its media" do
          assert_equal @fandom2, @character.fandom
        end
        context "with both removed" do
          setup do
            @character.remove_fandom(@fandom2)
            @character.reload
          end
          should "have 'No Fandom' as its fandom" do
            assert_equal Fandom.find_by_name("No Fandom"), @character.fandom
          end
        end
      end
      context "with the other fandom removed" do
        setup do
          @character.remove_fandom(@fandom2)
          @character.reload
        end
        should "still have the first as its media" do
          assert_equal @fandom, @character.fandom
        end
      end
    end
    context "which is canonical" do
      setup do
        @character.wrangle_canonical
      end
      context "which gets a pairing added" do
        setup do
          @pairing = create_pairing
          @character.add_pairing(@pairing)
        end
        should "have the pairing as a child" do
          assert @character.children.include?(@pairing)
        end
        should "mark the pairing as having characters" do
          assert @pairing.has_characters
        end
        context "which is later removed" do
          setup do
            @character.remove_pairing(@pairing)
          end
          should "not have the pairing as a child" do
            assert !@character.children.include?(@pairing)
          end
          should "mark the pairing as not having characters" do
            assert !@pairing.has_characters
          end
        end
      end
    end
  end
  context "a character" do
    setup do
      @character = create_character
    end
    context "which uses fandom update on names" do
      setup do
        @fandom = create_fandom(:canonical => true)
        @character.update_fandoms([@fandom.name])
        @character.reload
      end
      should "have fandoms" do
        assert_equal [@fandom], @character.fandoms
      end
      context "removing fandoms" do
        setup do
          @character.update_fandoms([""])
          @character.reload
        end
        should "have 'No Fandom' as fandom" do
          assert_equal Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME), @character.fandom
        end
        should "have 'No Fandom' as fandoms" do
          assert_equal [Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)], @character.fandoms
        end
      end
    end
  end

end
