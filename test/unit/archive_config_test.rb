require File.dirname(__FILE__) + '/../test_helper'

class ArchiveConfigTest < Test::Unit::TestCase
  def test_string
    assert_equal('do-not-reply@example.org', ArchiveConfig.RETURN_ADDRESS)
  end
  def test_hash
    assert_equal( { 
      "cs"=>"cs-CZ",
      "de"=>"de-DE",
      "en"=>"en-US",
      "es"=>"es-ES",
      "fi"=>"fi-FI",
      "fr"=>"fr-FR",
      "id"=>"id-ID",
      "it"=>"it-IT",
      "ja"=>"ja-JP",
      "nl"=>"nl-NL",
      "pt"=>"pt-BR",
      "ru"=>"ru-RU",
      "zh"=>"zh-CHS" 
     }, ArchiveConfig.SUPPORTED_LOCALES)
  end
  def test_all_caps
    assert  ArchiveConfig.SESSION_KEY
    assert !ArchiveConfig.SESSION_KEy
  end
  def test_number
    assert_equal 255, ArchiveConfig.TITLE_MAX
  end
end
