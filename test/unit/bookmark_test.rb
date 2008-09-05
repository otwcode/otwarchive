require File.dirname(__FILE__) + '/../test_helper'

class BookmarkTest < ActiveSupport::TestCase
  context "A Bookmark" do
    setup do
      @bookmark = create_bookmark
    end
    should_belong_to :bookmarkable
    should_belong_to :user
    should_have_many :taggings
    should_ensure_length_in_range :notes, (0..2500)
  end
  context "A public bookmark on a posted work" do
    setup do
      @bookmark = create_bookmark(:private => false)
      @bookmark.bookmarkable.update_attribute(:posted, true)
    end
    should "be visible" do
      assert @bookmark.visible
    end
    should "be visible en group" do
      assert Bookmark.visible.include?(@bookmark)
    end
    context "which is restricted" do
      setup do
        @bookmark.bookmarkable.update_attribute(:restricted, true)
      end
      should "not be visible by default" do
        assert !@bookmark.visible
      end
      should "be visible to a user" do
        assert @bookmark.visible(create_user)
      end
    end
    context "on an external work" do
      setup do
        @external_work = create_external_work
        @bookmark.bookmarkable = @external_work
        @bookmark.save
      end
      should "be visible" do
        assert @bookmark.visible
      end
    end
    context "on a user" do
      setup do
        @user = create_user
        @bookmark.bookmarkable = @user
        @bookmark.save
      end
      should "be visible" do
        assert @bookmark.visible
      end
    end
    context "on a deleted object" do
      setup do
        @work_to_destroy = create_work
        @bookmark.bookmarkable = @work_to_destroy
        @bookmark.save
        @work_to_destroy.destroy
      end
      should_eventually "have a test that correctly reports it is visible to the bookmark's creator" do
        #assert @bookmark.visible(@bookmark.user)
      end
      should "not be visible by default" do
        assert !@bookmark.visible
      end
      should "not be visible to a random user" do
        assert !@bookmark.visible(create_user)
      end      
    end
  end
  
  context "A private bookmark on a posted work" do
    setup do
      @bookmark = create_bookmark(:private => true)
      @bookmark.bookmarkable.update_attribute(:posted, true)
    end
    should "not be visible by default" do
      assert !@bookmark.visible
    end
    should "not be visible to a random user" do
      assert !@bookmark.visible(create_user)
    end
    should "be visible to it's owner" do
      assert @bookmark.visible(@bookmark.user)
    end
  end
end
