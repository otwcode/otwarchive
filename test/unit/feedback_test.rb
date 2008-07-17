require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < ActiveSupport::TestCase
  context "A Feedback" do
    setup do
      assert @feedback = create_feedback
    end
    should_require_attributes :comment
  end
end
