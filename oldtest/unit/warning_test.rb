require 'test_helper'

class WarningTest < ActiveSupport::TestCase

  context "a warning Tag" do
    setup do
      @warning = create_warning
      Warning.create_canonical(ArchiveConfig.WARNING_DEFAULT_TAG_NAME)
      Warning.create_canonical(ArchiveConfig.WARNING_NONE_TAG_NAME)    
      Warning.create_canonical(ArchiveConfig.WARNING_VIOLENCE_TAG_NAME)
      Warning.create_canonical(ArchiveConfig.WARNING_DEATH_TAG_NAME)
      Warning.create_canonical(ArchiveConfig.WARNING_NONCON_TAG_NAME)
      Warning.create_canonical(ArchiveConfig.WARNING_CHAN_TAG_NAME)
    end
    should "have a display name" do
      assert_equal ArchiveConfig.WARNING_CATEGORY_NAME, Warning::NAME
    end
    should "have a required tags" do
      assert Tag.find_by_name(ArchiveConfig.WARNING_DEFAULT_TAG_NAME).is_a?(Warning)
      assert Tag.find_by_name(ArchiveConfig.WARNING_NONE_TAG_NAME).is_a?(Warning)
      assert Tag.find_by_name(ArchiveConfig.WARNING_VIOLENCE_TAG_NAME).is_a?(Warning)
      assert Tag.find_by_name(ArchiveConfig.WARNING_DEATH_TAG_NAME).is_a?(Warning)
      assert Tag.find_by_name(ArchiveConfig.WARNING_NONCON_TAG_NAME).is_a?(Warning)
      assert Tag.find_by_name(ArchiveConfig.WARNING_CHAN_TAG_NAME).is_a?(Warning)
    end
  end
    
end
