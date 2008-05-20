require 'test/unit'
require File.dirname(__FILE__) + '/../lib/faker'

class FakerTest < Test::Unit::TestCase

  def setup
    @internet = Faker::Internet
    @name = Faker::Name
  end
  
  def test_numerify
    assert Faker.numerify('###').match(/\d{3}/)
  end

  def test_email
    assert @internet.email.match(/.+@.+\.\w+/)
  end
  
  def test_free_email
    assert @internet.free_email.match(/.+@(gmail|hotmail|yahoo)\.com/)
  end
  
  def test_user_name
    assert @internet.user_name.match(/[a-z]+((_|\.)[a-z]+)?/)
  end
  
  def test_user_name_with_arg
    assert @internet.user_name('bo peep').match(/(bo(_|\.)peep|peep(_|\.)bo)/)
  end
  
  def test_domain_name
    assert @internet.domain_name.match(/\w+\.\w+/)
  end
  
  def test_domain_word
    assert @internet.domain_word.match(/^\w+$/)
  end
  
  def test_domain_suffix
    assert @internet.domain_suffix.match(/^\w+(\.\w+)?/)
  end
  def test_name
    assert @name.name.match(/(\w+\.? ?){2,3}/)
  end
  
  def test_prefix
    assert @name.prefix.match(/[A-Z][a-z]+\.?/)
  end
  
  def test_suffix
    assert @name.suffix.match(/[A-Z][a-z]*\.?/)
  end
end
