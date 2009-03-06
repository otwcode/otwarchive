require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < ActiveSupport::TestCase
  context "A Feedback" do
    setup do
      assert @feedback = create_feedback
    end
    should_validate_presence_of :comment
  end
end
