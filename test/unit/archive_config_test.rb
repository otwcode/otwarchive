require 'test_helper'

class ArchiveConfigTest < Test::Unit::TestCase
  def test_string
    assert_equal('do-not-reply@example.org', ArchiveConfig.RETURN_ADDRESS)
  end
  def test_all_caps
    assert  ArchiveConfig.SESSION_KEY
    assert !ArchiveConfig.SESSION_KEy
  end
  def test_number
    assert_equal 255, ArchiveConfig.TITLE_MAX
  end
end
