require File.dirname(__FILE__) + '/../test_helper'

class RatingTest < ActiveSupport::TestCase

  context "a rating Tag" do
    should_have_many :taggings, :works, :bookmarks, :tags
    should_require_attributes :name
    should "have a display name" do
      assert_equal "Rating", Rating::NAME
    end
    should "have a required tags" do
      assert_equal ['Not Rated', 'Explicit', 'Mature', 'Teen And Up Audiences', 'General Audiences'].sort, Rating.all.map(&:name).sort
    end
    should "have adult tags" do
      assert Rating::DEFAULT.adult?
      assert Rating::EXPLICIT.adult?
      assert Rating::MATURE.adult?
      assert !Rating::TEEN.adult?
      assert !Rating::GENERAL.adult?
    end
  end
    
end
