require File.dirname(__FILE__) + '/../test_helper'

class FreeformTest < ActiveSupport::TestCase

  context "a freeform Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags, :children
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Tag", Freeform::NAME
    end
  end

  context "a freeform tag with children" do
    setup do
      @tag1 = Freeform.create(:name => "child1")
      @tag2 = Freeform.create(:name => "child2")
      @tag3 = Freeform.create(:name => "parent")
      @tag3.children = [@tag1, @tag2]
    end
    should "be their parent" do
      assert_equal @tag3, @tag1.parent
      assert_equal @tag3, @tag2.parent
    end
  end
  
  context "a work with a new freeform tag" do
    setup do
      @work = create_work
      @work.freeform_string = "a new freeform tag"
    end
    should "get the fandom of the work" do
      assert_equal @work.fandoms, [Freeform.find_by_name("a new freeform tag").fandom]
    end
  end

end
