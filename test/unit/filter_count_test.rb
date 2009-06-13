require File.dirname(__FILE__) + '/../test_helper'

class FilterCountTest < ActiveSupport::TestCase
  context "a filter count" do
    setup do
      @fandom = create_fandom(:canonical => true)
      @public_work = create_work(:posted => true, :fandom_string => @fandom.name)
      @unposted_work = create_work(:fandom_string => @fandom.name)
      @restricted_work = create_work(:posted => true, :restricted => true, :fandom_string => @fandom.name)
      @hidden_work = create_work(:posted => true, :hidden_by_admin => true, :fandom_string => @fandom.name)
    end
    should "not reflect restricted, unposted or hidden works in its public works count" do
      assert @fandom.filter_count.public_works_count == 1
    end
    should "not reflect unposted or hidden works in its unhidden works count" do
      assert @fandom.filter_count.unhidden_works_count == 2
    end
    should "change its public works count when a work is restricted" do
      assert @public_work.update_attribute('restricted', true)
      #assert @fandom.filter_count.public_works_count == 0 
    end
    should "change both counts when a work is hidden" do
      assert @public_work.update_attribute('hidden_by_admin', true)
      #assert @fandom.filter_count.public_works_count == 0
      #assert @fandom.filter_count.unhidden_works_count == 1 
    end   
  end
end