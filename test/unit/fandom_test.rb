require File.dirname(__FILE__) + '/../test_helper'

class FandomTest < ActiveSupport::TestCase

  context "a fandom Tag" do
    setup do
      @fandom = create_fandom
      @media = create_media(:canonical => true)
      @fandom.add_parent_by_id(@media.id)
    end
    should_require_attributes :name
    should "have a display name" do
      assert_equal ArchiveConfig.FANDOM_CATEGORY_NAME, Fandom::NAME
    end
    should "be able to add a media as a parent by id" do
      assert_equal @media, @fandom.media
    end
    context "with an added media" do
      setup do
        @media2 = create_media(:canonical => true)
        @fandom.add_media(@media2)
      end
      should "have both medias" do
        assert_equal [@media, @media2].sort, @fandom.medias.sort
      end
      context "with one media removed" do
        setup do
          @fandom.remove_media(@media)
          @fandom.reload
        end
        should "still have the other as its media" do
          assert_equal @media2, @fandom.media
        end
        context "with both removed" do
          setup do
            @fandom.remove_media(@media2)
            @fandom.reload
          end
          should "have 'No Media' as its media" do
            assert_equal Media.find_by_name("No Media"), @fandom.media
          end
        end
      end
      context "with the other media removed" do
        setup do
          @fandom.remove_media(@media2)
          @fandom.reload
        end
        should "still have the first as its media" do
          assert_equal @media, @fandom.media
        end
      end
    end
    context "which is canonical" do
      setup do
        @fandom.wrangle_canonical
      end
      context "with a freeform" do
        setup do
          @freeform = create_freeform
          @fandom.add_freeform(@freeform)
        end
        should "have the freeform as a child" do
          assert @fandom.children.include?(@freeform)
        end
        context "and later removed" do
          setup do
            @fandom.remove_freeform(@freeform)
          end
          should "not have the freeform in its children" do
            assert !@fandom.children.include?(@freeform)
          end
        end
      end
      context "using update on freeforms" do
        setup do
          @freeform = create_freeform
          @fandom.update_freeforms([@freeform.name])
        end
        should "have the freeform as a child" do
          assert @fandom.children.include?(@freeform)
        end
        context "and later removed" do
          setup do
            @fandom.update_freeforms([""])
          end
          should "not have the freeform in its children" do
            assert !@fandom.children.include?(@freeform)
          end
        end
      end
      context "with a pairing" do
        setup do
          @pairing = create_pairing
          @fandom.add_pairing(@pairing)
        end
        should "have the pairing as a child" do
          assert @fandom.children.include?(@pairing)
        end
        context "and later removed" do
          setup do
            @fandom.remove_pairing(@pairing)
          end
          should "not have the pairing in its children" do
            assert !@fandom.children.include?(@pairing)
          end
        end
      end
    end
  end
  context "a fandom" do
    setup do
      @fandom = create_fandom
    end
    context "which uses media update on names" do
      setup do
        @media = create_media(:canonical => true)
        @fandom.update_medias([@media.name])
        @fandom.reload
      end
      should "have new medias" do
        assert_equal [@media], @fandom.medias
      end
      should "have one as media" do
        assert_equal @media, @fandom.media
      end
      context "adding one" do
        setup do
          @media2 = create_media(:canonical => true)
          @fandom.update_medias([@media.name, @media2.name])
          @fandom.reload
        end
        should "have both as medias" do
          assert_equal [@media, @media2].sort, @fandom.medias.sort
        end
      end
      context "removing media" do
        setup do
          @fandom.update_medias([""])
          @fandom.reload
        end
        should "have 'No Media' as media" do
          assert_equal Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME), @fandom.media
        end
      end
    end
    context "with no media" do
      setup do
        @fandom.update_medias([""])
        @fandom.reload
      end
      should "have 'No Media' as media" do
        assert_equal Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME), @fandom.media
      end
    end
  end

end
