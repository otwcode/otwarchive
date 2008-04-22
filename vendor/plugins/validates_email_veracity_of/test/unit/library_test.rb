require 'test/unit'
require File.dirname(__FILE__) + '/../test_helper'


class DomainTest < Test::Unit::TestCase
  
  def test_servers_with_no_name
    domain = ValidatesEmailVeracityOf::Domain.new
    assert domain.exchange_servers(:timeout => 30).empty?, 'Should fail gracefully by returning an empty array of mail servers.'
    assert domain.address_servers(:timeout => 30).empty?, 'Should fail gracefully by returning an empty array of address servers.'
  end
  
  def test_with_name_of_gmail_dot_com
    domain = ValidatesEmailVeracityOf::Domain.new('gmail.com')
    assert !domain.exchange_servers(:timeout => 30).empty?, 'Should return mail servers for gmail dot com.'
    assert !domain.address_servers(:timeout => 30).empty?, 'Should return address servers for gmail dot com.'
  end
  
  def test_with_nonexistant_name
    domain = ValidatesEmailVeracityOf::Domain.new('idonot-exist.nil.xd')
    assert domain.exchange_servers(:timeout => 30).empty?, 'Should return a blank array.'
    assert domain.address_servers(:timeout => 30).empty?, 'Should return a blank array.'
  end
  
  def test_timeout
    domain = ValidatesEmailVeracityOf::Domain.new('nowhere-abcdef.ca')
    assert !domain.exchange_servers(:timeout => 0.0001), 'Should return false by default on mail server timeout.'
    assert !domain.address_servers(:timeout => 0.0001), 'Should return false by default on address server timeout.'
  end
  
  def test_timeout_when_fail_on_timeout_is_set
    domain = ValidatesEmailVeracityOf::Domain.new('nowhere-abcdef.ca')
    assert_nil domain.exchange_servers(:timeout => 0.0001, :fail_on_timeout => true), 'Should return nil on mail server timeout.'
    assert_nil domain.address_servers(:timeout => 0.0001, :fail_on_timeout => true), 'Should return nil on address server timeout.'
  end

end


class EmailAddressTest < Test::Unit::TestCase
  
  def test_with_invalid_domain
    email = ValidatesEmailVeracityOf::EmailAddress.new('carsten@invalid.com')
    assert !email.domain_is_valid?(:invalid_domains => %w[invalid.com]), 'Should not pass as a valid domain.'
  end
  
  def test_domain_has_servers_with_no_email_address
    email = ValidatesEmailVeracityOf::EmailAddress.new
    assert !email.domain_has_servers?(:timeout => 30), 'Should fail gracefully.'
  end
  
  def test_malformed_email_addresses
    malformed_addresses.each do |address|
      email = ValidatesEmailVeracityOf::EmailAddress.new(address)
      assert_nil email.pattern_is_valid?, 'Should fail pattern validation.'
    end
  end
  
  def test_well_formed_email_addresses
    well_formed_addresses.each do |address|
      email = ValidatesEmailVeracityOf::EmailAddress.new(address)
      assert email.pattern_is_valid?, 'Should pass pattern validation.'
    end
  end
  
  def test_itsme_at_heycarsten_dot_com
    email = ValidatesEmailVeracityOf::EmailAddress.new('itsme@heycarsten.com')
    assert email.domain_has_servers?(:timeout => 30), 'Should have servers.'
  end
  
  def test_nobody_at_carstensnowhereland_dot_ca
    email = ValidatesEmailVeracityOf::EmailAddress.new('nobody@carstensnowhereland.ca')
    assert !email.domain_has_servers?(:timeout => 30), 'Should not have mail servers.'
  end
  
  def test_an_object_with_no_address
    email = ValidatesEmailVeracityOf::EmailAddress.new
    assert_equal ValidatesEmailVeracityOf::Domain, email.domain.class, 'Should still have a domain object.'
  end
  
  def test_an_object_with_an_address_but_no_domain
    email = ValidatesEmailVeracityOf::EmailAddress.new('niltor@')
    assert_equal '', email.domain.name, 'Should have a domain object with no name.'
  end
  
end