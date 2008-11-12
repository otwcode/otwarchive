require File.dirname(__FILE__) + '/../test_helper'

class GenreTest < ActiveSupport::TestCase

  context "a genre Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags, :freeforms
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Genre", Genre::NAME
    end
  end  

  context "a work with a new genre tag" do
    setup do
      @work = create_work
      @work.genre_string = "a new genre tag"
    end
    should "get the fandom of the work" do
      assert_equal @work.fandoms, [Genre.find_by_name("a new genre tag").fandom]
    end
  end

end
