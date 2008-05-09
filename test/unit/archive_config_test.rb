require File.dirname(__FILE__) + '/../test_helper'

class ArchiveConfigTest < Test::Unit::TestCase
  def test_string
    assert_equal('do-not-reply@test.com', ArchiveConfig.RETURN_ADDRESS)
  end
  def test_hash
    assert_equal( {"fr"=>"fr-FR", "en"=>"en-US"} , ArchiveConfig.SUPPORTED_LOCALES)
  end
  def test_misspelling
    assert  ArchiveConfig.SESSION_KEY
    assert !ArchiveConfig.SESSION_KEy
  end
end
