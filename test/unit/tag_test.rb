require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  context "a Tag" do
    setup do
      @name = "all lower-case/words"
      @tag = create_tag(:name => @name)
    end
    should_belong_to :tag_category
    should_have_many :taggings
    should_ensure_length_in_range :name, (1..42), :short_message => /blank/, :long_message => /too long/
    should_require_attributes :name
    should_allow_values_for :adult, true, false
    should_allow_values_for :name, '"./?~!@#$%^&()_-+=', "1234567890", "spaces are not tag separators"
    should_not_allow_values_for :name, "commas, aren't allowed", :message => /commas/
    should_not_allow_values_for :name, "asterisks* aren't allowed", :message => /asterisk/
    should_not_allow_values_for :name, "angle brackets < aren't allowed", :message => /angle/
    should_not_allow_values_for :name, "angle brackets > aren't allowed", :message => /angle/
    should "invert valid and banned" do
      assert_equal @tag.valid?, !@tag.banned?
    end
    context "with whitespace" do
      setup do
        @tag = create_tag(:name => "   whitespace'll   (be    stripped)    ")
      end
      should "be stripped" do
        assert_equal "whitespace'll (be stripped)", @tag.name
      end
    end
    context "which is made canonical" do
      setup do
        @tag.update_attribute(:canonical, true)
      end
      should_eventually "get prettified" do
        assert_equal "All Lower-Case/Words", @tag.name      
      end
      should "revert if un-canonicalized" do
        @tag.update_attribute(:canonical, false)
        @tag.reload
        assert_equal @name, @tag.name
      end
    end
    context "of a posted work" do
      setup do
        @work = create_work
        @work.update_attribute(:posted, true)
        tagging = create_tagging(:taggable => @work, :tag => @tag)  
        @tag.reload
      end
      should "show the work" do
        assert @tag.visible('Works').include?(@work)
      end
      context "which is restricted" do
        setup do
          @work.update_attribute(:restricted, true)
        end
        should "not show the work by default" do
          assert !@tag.visible('Works').include?(@work)
        end
        should "show the work to a user" do
          assert @tag.visible('Works', create_user).include?(@work)
        end
      end
    end
    context "of a bookmark on a posted work" do
      setup do
        @work = create_work
        @work.update_attribute(:posted, true)
        @bookmark = create_bookmark(:bookmarkable => @work)
        tagging = create_tagging(:taggable => @bookmark, :tag => @tag)  
      end
      should "show the bookmark" do
        assert @tag.bookmarks.visible.include?(@bookmark)
      end
      context "which is private" do
        setup do
          @bookmark.update_attribute(:private, true)
        end
        should "not show the bookmark by default" do
          assert !@tag.visible('Bookmarks').include?(@bookmark)
        end
        should "not show the bookmark to other users" do
          assert !@tag.visible('Bookmarks', create_user).include?(@bookmark)
        end
        should "show the bookmark to its owner" do
          assert @tag.visible('Bookmarks', @bookmark.user).include?(@bookmark)
        end
      end
    end
  end
end
