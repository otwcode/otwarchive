require File.dirname(__FILE__) + '/../test_helper'

class ReadingTest < ActiveSupport::TestCase
  # Test associations
 
  context "A reading" do
    setup do
      @reading = create_reading
    end
    should_belong_to :user, :work
  end

end
