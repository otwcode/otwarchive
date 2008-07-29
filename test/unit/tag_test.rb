require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  context "a Tag" do
    setup do
      @name = "all lower-case/words"
      @tag = create_tag(:name => @name)
    end
    should_belong_to :tag_category
    should_have_many :taggings
    should_ensure_length_in_range :name, (1..42), :short_message => /blank/
    should_require_attributes :name
    should_allow_values_for :name, '"./?~!@#$%^&()_-+=', "1234567890", "space's are not tag separators"
    should_not_allow_values_for :name, "commas, aren't allowed", "colons: are not allowed", :message => /commas, colons/
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
    context "which is synonymous" do
      setup do
        @tag2 = create_tag
        tagging = create_tagging(:taggable => @tag2, :tag => @tag, :tag_relationship => TagRelationship.synonym)          
      end
      should "be in the other tag's synonym group" do
        assert @tag2.synonyms.include?(@tag)
      end
      should "have the other tag in its synonym group" do
        assert @tag.synonyms.include?(@tag2)
      end
    end
    context "which is ambiguous" do
      setup do
        @tag2 = create_tag 
        tagging = create_tagging(:taggable => @tag2, :tag => @tag, :tag_relationship => TagRelationship.disambiguate)          
      end
      should "be in the other tag's 'possibly related' group" do
        assert @tag2.disambiguates.include?(@tag)
      end
      should "have the other tag in its own 'possibly related' group" do
        assert @tag.disambiguates.include?(@tag2)
      end
    end
    context "which is made canonical" do
      setup do
        @tag.update_attribute(:canonical, true)
      end
      should "get prettified" do
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
        @work.update_attributes(:posted => true)
        @bookmark = create_bookmark(:bookmarkable => @work)
        tagging = create_tagging(:taggable => @bookmark, :tag => @tag)  
      end
      should "show the bookmark" do
        assert @tag.visible('Bookmarks').include?(@bookmark)
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
    context "of a tag" do
      setup do
        @tag2 = create_tag
        tagging = create_tagging(:taggable => @tag2, :tag => @tag)  
      end
      should "be visible" do
        assert @tag.visible('Tags').include?(@tag2)      
      end
      context "which is banned" do
        setup do
          @tag2.update_attribute(:banned, true)
        end
        should "not be visible" do
          assert !@tag.visible('Tags').include?(@tag2) 
        end
      end
    end
  end
end
