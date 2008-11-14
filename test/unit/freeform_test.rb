require File.dirname(__FILE__) + '/../test_helper'

class FreeformTest < ActiveSupport::TestCase

  context "a freeform Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags
    should_belong_to :genre
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Tag", Freeform::NAME
    end
    context "when added to a genre" do
      setup do
        @freeform = create_freeform
        @genre = create_genre
        @freeform.add_to_genre(@genre)        
      end
      should "make the genre canonical" do
        assert @genre.canonical
      end
      should "be added" do
        assert_equal @genre, @freeform.genre
      end
    end
  end

  context "a new freeform tag on a work" do
    setup do
      @work = create_work
      @work.freeform_string = "a new freeform tag"
      assert @freeform = Freeform.find_by_name("a new freeform tag")
    end
    should "get the fandom of the work" do
      assert_equal @work.fandoms, [@freeform.fandom]
    end
    context "which is added to a genre" do
      setup do
        @genre = create_genre
        @freeform.add_to_genre(@genre)
      end
      should "add the genre to the works" do
        assert_equal [@genre], @work.genres
      end
      should "not remove the freeform tag" do
        assert_equal [@freeform], @work.freeforms
      end
    end
  end

end
