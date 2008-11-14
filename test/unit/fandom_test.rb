require File.dirname(__FILE__) + '/../test_helper'

class FandomTest < ActiveSupport::TestCase

  context "a fandom Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags, :characters, :pairings, :freeforms
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Fandom", Fandom::NAME
    end
  end
 
  context "a non-canonical fandom tag" do
     setup do
       @fandom = Fandom.create(:name => "non canonical")
       @character = Character.create(:name => "something", :fandom_id => @fandom.id)
       @pairing = Pairing.create(:name => "something", :fandom_id => @fandom.id)
       @freeform = Freeform.create(:name => "something", :fandom_id => @fandom.id)
       @canonical = Fandom.create(:name => "canonical", :canonical => true)
       @fandom.synonym = @canonical
       @fandom.reload
     end
     should "point its children at its synonym" do
       assert_equal @canonical, Pairing.find(@pairing.id).fandom
       assert_equal @canonical, Character.find(@character.id).fandom
       assert_equal @canonical, Freeform.find(@freeform.id).fandom
     end
  end
  
  context "a work with a fandom tag" do
     setup do 
       @fandom = create_fandom
       @work = create_work(:fandom_string => @fandom.name)
     end
     should "not count the work if it isn't visible" do
       assert_nil @work.visible
       assert_equal 0, @fandom.visible_works_count
     end
     context "for a posted work" do
       setup { @work.update_attribute(:posted, true) }
       should "count the work if it is visible" do     
         assert @work.visible
         assert_equal 1, @fandom.visible_works_count
       end
       context "for a restricted work" do
         setup { @work.update_attribute(:restricted, true) }
         should "count the work if logged in" do
           User.current_user = create_user
           assert_equal 1, @fandom.visible_works_count
         end
         should "not count the work if not logged in" do
           User.current_user = :false
           assert_equal 0, @fandom.visible_works_count
         end
         should "count the work if an admin" do
           User.current_user = create_admin
           assert_equal 1, @fandom.visible_works_count
         end
       end
       context "for a hidden_by_admin work" do
         setup { @work.update_attribute(:hidden_by_admin, true) }
         should "not count the work if logged in" do
           User.current_user = create_user
           assert_equal 0, @fandom.visible_works_count
         end
         should "count the work if an admin" do
           User.current_user = create_admin
           assert_equal 1, @fandom.visible_works_count
         end
       end
     end
  end

  context "tags by_fandom" do
    setup do
      @fandom = create_fandom
      @freeform = create_freeform(:fandom_id => @fandom.id)
      @character = create_character(:fandom_id => @fandom.id)
      @fandom2 = create_fandom
      @freeform2 = create_freeform(:fandom_id => @fandom2.id)
      @freeform3 = create_freeform(:fandom_id => nil)
    end
    should "find tags in a single fandom" do
      assert_equal [@freeform, @character], Tag.by_fandom(@fandom)
    end
    should "count tags in a single fandom" do
      assert_equal 2, Tag.count_by_fandom(@fandom)
    end
    should "find tags in multiple fandoms" do
      assert_equal [@freeform, @freeform2], Freeform.by_fandom(@fandom, @fandom2)
    end
    should "count tags in multiple fandoms" do
      assert_equal 3, Tag.count_by_fandom(@fandom, @fandom2)
    end
    should "find tags in no fandoms" do
      assert_equal [@freeform3], Freeform.by_fandom(nil)
    end
    should "count tags in no fandoms" do
      assert_equal 1, Freeform.count_by_fandom(nil)
    end
  end

end
