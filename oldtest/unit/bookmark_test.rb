require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  context "A Bookmark" do
    setup do
      assert create_bookmark
    end
    should_belong_to :bookmarkable
    should_belong_to :pseud
    should_have_many :taggings
    should_have_many :tags, :through => :taggings
    should_ensure_length_in_range :notes, (0..ArchiveConfig.NOTES_MAX), :long_message => /must be less/
    should_have_scope :public

  end
  context "A public bookmark on a posted work" do
    setup do
      @bookmark = create_bookmark(:private => false)
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
    end
    should "be visible" do
      assert @bookmark.visible
    end
    should "be visible en group" do
      assert_contains(Bookmark.visible, @bookmark)
    end
    context "which is restricted" do
      setup do
        @bookmark.bookmarkable.update_attribute(:restricted, true)
      end
      should "not be visible by default" do
        assert !@bookmark.visible
      end
      should "not be visible en group" do
        assert_does_not_contain(Bookmark.visible, @bookmark)
      end
      should "be visible to a user" do
        assert @bookmark.visible(create_user)
      end
      should "be visible to an admin" do
        assert @bookmark.visible(create_admin)
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
      should "be visible to the bookmark's creator" do
        assert @bookmark.visible(@bookmark.pseud.user)
      end
      should "not be visible by default" do
        assert !@bookmark.visible
      end
      should "not be visible to a random user" do
        assert !@bookmark.visible(create_user)
      end
      should "be visible to an admin" do
        assert @bookmark.visible(create_admin)
      end
    end
    context "on a work hidden by an admin" do
      setup do
        @hidden_work = create_work
        @bookmark.bookmarkable = @hidden_work
        @bookmark.save
        @hidden_work.hidden_by_admin
      end
      should "be visible to the bookmark's creator" do
        assert @bookmark.visible(@bookmark.pseud.user)
      end
      should "be visible to an admin" do
        assert @bookmark.visible(create_admin)
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
    should "not be visible to an admin" do
      assert !@bookmark.visible(create_admin)
    end
    should "be visible to its owner" do
      assert @bookmark.visible(@bookmark.pseud.user)
    end
  end
  
  context "A bookmark hidden by an admin on a posted work" do
    setup do
      @bookmark = create_bookmark(:private => false, :hidden_by_admin => true)
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
    end
    should "not be visible by default" do
      assert !@bookmark.visible
    end
    should "not be visible en group" do
      assert_does_not_contain(Bookmark.visible, @bookmark)
    end
    should "not be visible to a random user" do
      assert !@bookmark.visible(create_user)
    end
    should "be visible to an admin" do
      assert @bookmark.visible(create_admin)
    end
    should "be visible to its owner" do
      assert @bookmark.visible(@bookmark.pseud.user)
    end
  end
  
end
