require 'test_helper'

class PreferenceTest < ActiveSupport::TestCase
  # Test associations
  context "A preference" do
    setup do
      assert create_preference
    end
    should_belong_to :user
    should_not_allow_values_for :work_title_format, "ab!cd", :message => /contain/
    should_allow_values_for :work_title_format, "ab cd", "ab.cd", "ab_cd", "ab,cd", "ab-cd", "ab12"
  end
end
