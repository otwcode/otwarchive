require File.dirname(__FILE__) + '/test_helper'

class ActionMailerTest < Test::Unit::TestCase
  include Globalize
  fixtures :globalize_languages, :globalize_countries

  class GlobalizeMailer < ActionMailer::Base
    @@subject = "Test"
    @@from = "test@test.com"  
    
    def test
      @charset = 'utf-8'
      recipients      'recipient@test.com'
      subject         @@subject
      from            @@from
      body(:recipient => "recipient")
    end
  end

  def setup
    GlobalizeMailer.template_root = File.dirname(__FILE__)
    Locale.set("en-US")
  end

  def test_en_us
    mail = GlobalizeMailer.create_test
    assert_match "This is the english [en-US] mail.", mail.to_s
  end

  def test_en
    Locale.set('en')
    mail = GlobalizeMailer.create_test
    assert_match "This is the english [en] mail.", mail.to_s
  end

  def test_he_il
    Locale.set('he-IL')
    mail = GlobalizeMailer.create_test
    assert_match "This is the hebrew [he] mail.", mail.to_s
  end

  def test_he
    Locale.set('he')
    mail = GlobalizeMailer.create_test
    assert_match "This is the hebrew [he] mail.", mail.to_s
  end

  def test_nil
    Locale.set(nil)
    mail = GlobalizeMailer.create_test
    assert_match "This is the default mail.", mail.to_s
  end

end
