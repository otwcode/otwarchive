require File.dirname(__FILE__) + '/../test_helper'

class FreeformTest < ActiveSupport::TestCase

  context "a freeform Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Tag", Freeform::NAME
    end
  end

  context "a work with a new freeform tag" do
    setup do
      @work = create_work
      @work.freeform_string = "a new freeform tag"
      assert @freeform = Freeform.find_by_name("a new freeform tag")
    end
    should "get the fandom of the work" do
      assert_equal @work.fandoms, [@freeform.fandom]
    end
    context "when the freeform tag gets a synonym" do
      setup do
        @genre = create_genre(:canonical => true)
        @freeform.add_genre(@genre)
      end
      should "have the genre added" do
        assert_equal [@genre], @work.genres
      end
      should "not have the freeform removed" do
        assert_equal [@freeform], @work.freeforms
      end
    end
  end

end
