require File.dirname(__FILE__) + '/../test_helper'

class FandomTest < ActiveSupport::TestCase

  context "a fandom Tag" do
    setup do
      @myfandom = create_fandom
      @media = create_media(:canonical => true)
      @myfandom.add_parent_by_id(@media.id)
      @myfandom.reload
    end
    should_validate_presence_of :name
    should "have a display name" do
      assert_equal ArchiveConfig.FANDOM_CATEGORY_NAME, Fandom::NAME
    end
    should "be able to add a media as a parent by id" do
      assert_equal @media, @myfandom.media
    end
    context "with an added media" do
      setup do
        @media2 = create_media(:canonical => true)
        @myfandom.add_media(@media2)
      end
      should "have both medias" do
        assert_same_elements [@media, @media2], @myfandom.medias
      end
      context "with one media removed" do
        setup do
          @myfandom.remove_media(@media)
          @myfandom.reload
        end
        should "still have the other as its media" do
          assert_contains @myfandom.medias, @media2
        end
        context "with both removed" do
          setup do
            @myfandom.remove_media(@media2)
            @myfandom.reload
          end
          should "have 'Uncategorized Fandoms' as its media" do
            assert_equal Media.uncategorized, @myfandom.media
          end
        end
      end
      context "with the other media removed" do
        setup do
          @myfandom.remove_media(@media2)
          @myfandom.reload
        end
        should "still have the first as its media" do
          assert_equal @media, @myfandom.media
        end
      end
    end
    context "which is canonical" do
      setup do
        @myfandom.wrangle_canonical
      end
      context "with a freeform" do
        setup do
          @freeform = create_freeform
          @myfandom.add_freeform(@freeform)
        end
        should "have the freeform as a child" do
          assert_contains(@myfandom.children, @freeform)
        end
        context "and later removed" do
          setup do
            @myfandom.remove_freeform(@freeform)
          end
          should "not have the freeform in its children" do
            assert_does_not_contain(@myfandom.children, @freeform)
          end
        end
      end
      context "using update on freeforms" do
        setup do
          @freeform = create_freeform
          @myfandom.update_freeforms([@freeform.name])
        end
        should "have the freeform as a child" do
          assert_contains(@freeform.parents, @myfandom)
        end
        context "and later removed" do
          setup do
            @myfandom.update_freeforms([""])
          end
          should "not have the freeform in its children" do
            assert_does_not_contain(@myfandom.children, @freeform)
          end
        end
      end
      context "with a pairing" do
        setup do
          @pairing = create_pairing
          @myfandom.add_pairing(@pairing)
        end
        should "have the pairing as a child" do
          assert_contains(@myfandom.children, @pairing)
        end
        context "and later removed" do
          setup do
            @myfandom.remove_pairing(@pairing)
          end
          should "not have the pairing in its children" do
            assert_does_not_contain(@myfandom.children, @pairing)
          end
        end
      end
    end
  end
  context "a fandom" do
    setup do
      @myfandom = create_fandom
    end
    context "which uses media update on names" do
      setup do
        @media = create_media(:canonical => true)
        @myfandom.update_medias([@media.name])
        @myfandom.reload
      end
      should "have new medias" do
        assert_equal [@media], @myfandom.medias
      end
      should "have one as media" do
        assert_equal @media, @myfandom.media
      end
      context "adding one" do
        setup do
          @media2 = create_media(:canonical => true)
          @myfandom.update_medias([@media.name, @media2.name])
          @myfandom.reload
        end
        should "have both as medias" do
          assert_same_elements [@media, @media2], @myfandom.medias
        end
      end
      context "removing media" do
        setup do
          @myfandom.update_medias([""])
          @myfandom.reload
        end
        should "have 'Uncategorized Fandoms' as media" do
          assert_equal Media.uncategorized, @myfandom.media
        end
      end
    end
    context "with no media" do
      setup do
        @myfandom.update_medias([""])
        @myfandom.reload
      end
      should "have 'Uncategorized Fandoms' as media" do
        assert_equal Media.uncategorized, @myfandom.media
      end
    end
  end

end
