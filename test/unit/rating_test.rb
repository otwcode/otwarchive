require 'test_helper'

class RatingTest < ActiveSupport::TestCase
  context "a rating Tag" do
    setup do
      @rating = create_rating
      Rating.create_canonical(ArchiveConfig.RATING_DEFAULT_TAG_NAME, true)
      Rating.create_canonical(ArchiveConfig.RATING_EXPLICIT_TAG_NAME, true)
      Rating.create_canonical(ArchiveConfig.RATING_MATURE_TAG_NAME, true)
      Rating.create_canonical(ArchiveConfig.RATING_TEEN_TAG_NAME, false)
      Rating.create_canonical(ArchiveConfig.RATING_GENERAL_TAG_NAME, false)
    end
    should "have a display name" do
      assert_equal ArchiveConfig.RATING_CATEGORY_NAME, Rating::NAME
    end
    should "have required tags" do
      assert Tag.find_by_name(ArchiveConfig.RATING_DEFAULT_TAG_NAME).is_a?(Rating)
      assert Tag.find_by_name(ArchiveConfig.RATING_EXPLICIT_TAG_NAME).is_a?(Rating)
      assert Tag.find_by_name(ArchiveConfig.RATING_MATURE_TAG_NAME).is_a?(Rating)
      assert Tag.find_by_name(ArchiveConfig.RATING_TEEN_TAG_NAME).is_a?(Rating)
      assert Tag.find_by_name(ArchiveConfig.RATING_GENERAL_TAG_NAME).is_a?(Rating)
    end
    should "have adult tags" do
      assert Rating.find_by_name(ArchiveConfig.RATING_DEFAULT_TAG_NAME).adult?
      assert Rating.find_by_name(ArchiveConfig.RATING_EXPLICIT_TAG_NAME).adult?
      assert Rating.find_by_name(ArchiveConfig.RATING_MATURE_TAG_NAME).adult?
      assert !Rating.find_by_name(ArchiveConfig.RATING_TEEN_TAG_NAME).adult?
      assert !Rating.find_by_name(ArchiveConfig.RATING_GENERAL_TAG_NAME).adult?
    end
    context "on a work" do
      setup {@work = create_work }
      should "determine the work's adult content" do
        @work.rating_string = ArchiveConfig.RATING_EXPLICIT_TAG_NAME
        assert @work.adult?
        @work.rating_string = ArchiveConfig.RATING_GENERAL_TAG_NAME
        assert !@work.adult?
      end
    end
  end
    
end
