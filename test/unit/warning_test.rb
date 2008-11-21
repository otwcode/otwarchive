require File.dirname(__FILE__) + '/../test_helper'

class WarningTest < ActiveSupport::TestCase

  context "a warning Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.WARNING_CATEGORY_NAME, Warning::NAME
    end
    should "have a required tags" do
      assert_equal [ArchiveConfig.WARNING_DEFAULT_TAG_NAME,  ArchiveConfig.WARNING_NONE_TAG_NAME,  ArchiveConfig.WARNING_SOME_TAG_NAME,  ArchiveConfig.WARNING_VIOLENCE_TAG_NAME,  ArchiveConfig.WARNING_DEATH_TAG_NAME,  ArchiveConfig.WARNING_NONCON_TAG_NAME,  ArchiveConfig.WARNING_CHAN_TAG_NAME].sort, Warning.all.map(&:name).sort
    end
  end
    
end
