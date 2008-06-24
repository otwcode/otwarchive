require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < ActiveSupport::TestCase
  # Test validations
  def test_validations_fail
    # validates_presence_of :comment
    feedback = new_feedback(:comment => "")
    assert !feedback.save
  end
  
  def test_validations_pass
    # test example_data.rb
    assert create_feedback
  end
end
