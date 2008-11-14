require File.dirname(__FILE__) + '/../test_helper'

class GenreTest < ActiveSupport::TestCase

  context "a genre Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags, :freeforms
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Genre", Genre::NAME
    end
    context "which gets a freeform tag" do
      setup do
        @genre = create_genre
        @freeform = create_freeform(:name => "a freeform tag")
        @freeform.add_to_genre(@genre)
      end
      should "make the genre canonical" do
        assert @genre.canonical
      end
    end
  end

  context "a work with a freeform tag that belongs to a genre" do
    setup do
      @freeform = create_freeform(:name => "a freeform tag")
      @genre = create_genre
      @freeform.add_to_genre(@genre)
      @work = create_work
      @work.freeform_string = "a freeform tag"
    end
    should "get the genre of the freeform" do
      assert_equal [@genre],  @work.genres
    end
  end

end
