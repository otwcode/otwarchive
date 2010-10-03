require 'test_helper'

class FandomTest < ActiveSupport::TestCase

  context "a fandom Tag" do
    setup do
      Fandom.create_canonical(ArchiveConfig.FANDOM_NO_TAG_NAME)
      @myfandom = create_fandom
      @media = create_media(:canonical => true)
      @myfandom.add_association(@media)
      @myfandom.reload
    end
    should_validate_presence_of :name
    should "have a display name" do
      assert_equal ArchiveConfig.FANDOM_CATEGORY_NAME, Fandom::NAME
    end
    should "have required tags" do
      assert Tag.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME).is_a?(Fandom)
    end
    should "be able to add a media" do
      assert_contains @myfandom.medias, @media
    end
    context "with an added media" do
      setup do
        @media2 = create_media(:canonical => true)
        @myfandom.add_association(@media2)
      end
      should "have both medias" do
        assert_same_elements [@media, @media2], @myfandom.medias
      end
      context "with one media removed" do
        setup do
          @myfandom.remove_association(@media)
          @myfandom.reload
        end
        should "still have the other as its media" do
          assert_contains @myfandom.medias, @media2
        end
        context "with both removed" do
          setup do
            @myfandom.remove_association(@media2)
            @myfandom.reload
          end
          should "have 'Uncategorized Fandoms' as its media" do
            assert_contains @myfandom.medias, Media.uncategorized
          end
        end
      end
    end
    context "which is canonical" do
      setup do
        @myfandom.update_attributes(:canonical => true)
      end
      context "with a freeform" do
        setup do
          @freeform = create_freeform
          @myfandom.add_association(@freeform)
        end
        should "have the freeform as a child" do
          assert_contains(@myfandom.children, @freeform)
        end
        context "and later removed" do
          setup do
            @myfandom.remove_association(@freeform)
          end
          should "not have the freeform in its children" do
            assert_does_not_contain(@myfandom.children, @freeform)
          end
        end
      end
      context "with a relationship" do
        setup do
          @relationship = create_relationship
          @myfandom.add_association(@relationship)
        end
        should "have the relationship as a child" do
          assert_contains(@myfandom.children, @relationship)
        end
        context "and later removed" do
          setup do
            @myfandom.remove_association(@relationship)
          end
          should "not have the relationship in its children" do
            assert_does_not_contain(@myfandom.children, @relationship)
          end
        end
      end
    end
  end
  context "a fandom with no medias" do
    setup do
      @myfandom = create_fandom
    end
    should "have 'Uncategorized Fandoms' as media" do
      assert_contains @myfandom.medias, Media.uncategorized
    end
  end

end
