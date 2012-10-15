require 'test_helper'

class FilterCountTest < ActiveSupport::TestCase
  context "a filter count" do
    setup do
      @fandom = create_fandom(:canonical => true)
      @fandom2 = create_fandom(:canonical => true)
      @public_work = create_work(:posted => true, :fandom_string => @fandom.name, 
                                  :rating_string => ArchiveConfig.RATING_TEEN_TAG_NAME,
                                  :warning_strings => [ArchiveConfig.WARNING_NONE_TAG_NAME], 
                                  :category_string => ArchiveConfig.CATEGORY_GEN_TAG_NAME)
      @unposted_work = create_work(:fandom_string => @fandom.name)
      @restricted_work = create_work(:posted => true, :restricted => true, :fandom_string => @fandom.name)
      @hidden_work = create_work(:posted => true, :hidden_by_admin => true, :fandom_string => @fandom.name)
    end
    should "not reflect restricted, unposted or hidden works in its public works count" do
      assert_equal 1, @fandom.filter_count.public_works_count
    end
    should "not reflect unposted or hidden works in its unhidden works count" do
      assert_equal 2, @fandom.filter_count.unhidden_works_count
    end
    should "increase when a new work is added" do
      assert_difference('@fandom.filter_count.unhidden_works_count') do
        create_work(:posted => true, :fandom_string => @fandom.name)
        @fandom.filter_count.reload     
      end
    end
    should "decrease when a work is removed" do
      assert_difference('@fandom.filter_count.unhidden_works_count', -1) do
        @public_work.update_attributes(:fandom_string => @fandom2.name)
        @fandom.reload 
      end
    end
    should "change its public works count when a work is restricted" do
      @public_work.restricted = true
      @public_work.save
      assert_equal 0, @fandom.filter_count.public_works_count 
    end
    should "change its unhidden works count when a work is hidden" do
      @public_work.hidden_by_admin = true
      @public_work.save
      assert_equal 1, @fandom.filter_count.unhidden_works_count 
    end
    context "for a tag with mergers that have works" do
      setup do
        @merger = create_fandom
        @public_work.update_attributes(:restricted => false, :hidden_by_admin => false, :fandom_string => @merger.name)
        @canonical = create_fandom(:canonical => true)
        @merger.update_attributes(:merger_id => @canonical.id)
      end
      should "include the works that belong to its mergers" do
        assert_equal 1, @canonical.filter_count.public_works_count
      end 
    end       
  end
end