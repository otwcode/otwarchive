require File.dirname(__FILE__) + '/../test_helper'

class BookmarkTest < ActiveSupport::TestCase
  context "A Bookmark, in general" do
    setup do
      @bookmark = create_bookmark()
    end
    should_belong_to :bookmarkable
    should_belong_to :user
    should_have_many :taggings
    should_ensure_length_in_range :notes, (0..2500)
    should "invert public and private" do
      assert_equal @bookmark.private?, !@bookmark.public?
    end
  end
  context "A Bookmark on a work" do
    setup do
      @work = create_work
      @bookmark = create_bookmark(:bookmarkable => @work)
    end
    should "have a work bookmarkable type" do
      assert_equal "Work", @bookmark.bookmarkable_type
    end
  end
  context "A Bookmark on an external work" do
    setup do
      assert @work = create_external_work
      assert @bookmark = create_bookmark(:bookmarkable => @work)
    end
    should "have an external work bookmarkable type" do
      assert_equal "ExternalWork", @bookmark.bookmarkable_type
    end
  end
end
