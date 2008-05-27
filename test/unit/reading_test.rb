require File.dirname(__FILE__) + '/../test_helper'

class ReadingTest < ActiveSupport::TestCase
  # Test associations
  def test_belongs_to_user
    user = create_user
    reading = create_reading(:user => user)
    assert_equal user, reading.user
  end
  def test_belongs_to_work
    work = create_work
    reading = create_reading(:work => work)
    assert_equal work, reading.work
  end
end
