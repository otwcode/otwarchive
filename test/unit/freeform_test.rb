require File.dirname(__FILE__) + '/../test_helper'

class FreeformTest < ActiveSupport::TestCase

  context "a freeform Tag" do
    should "have a display name" do
      assert_equal ArchiveConfig.FREEFORM_CATEGORY_NAME, Freeform::NAME
    end
  end

end
