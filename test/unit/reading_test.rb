require 'test_helper'

class ReadingTest < ActiveSupport::TestCase
  # Test associations
 
  context "A reading" do
    setup do
      assert create_reading
    end
    should_belong_to :user, :work
  end

end
