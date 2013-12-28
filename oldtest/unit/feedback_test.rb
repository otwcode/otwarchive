require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  context "A Feedback" do
    setup do
      assert create_feedback
    end
    should_validate_presence_of :summary
    should_validate_presence_of :comment
    should_not_allow_values_for :email, "abcd", :message => /invalid/
    should_allow_values_for :email, "", "user@google.com"
  end
end
