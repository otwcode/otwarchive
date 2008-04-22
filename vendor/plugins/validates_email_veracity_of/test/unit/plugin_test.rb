require 'test/unit'
require File.dirname(__FILE__) + '/../test_helper'


class ValidatesEmailVeracityOfTest < Test::Unit::TestCase
  
  def test_malformed_addresses
    malformed_addresses.each do |email|
      assert !Email.new(:address => email).valid?, 'Should not validate.'
    end
  end
  
  def test_well_formed_addresses
    well_formed_addresses.each do |email|
      assert EmailSkipRemote.new(:address => email).valid?, 'Should validate when skip remote is set.'
    end
  end
  
  def test_real_addresses
    real_addresses.each do |email|
      assert Email.new(:address => email).valid?, 'Should validate.'
    end
  end
  
  def test_email_addresses_with_nonexistant_domains
    nonexistant_addresses.each do |email|
      assert !Email.new(:address => email).valid?, 'Should not validate.'
    end
  end
  
  def test_email_address_with_mx_lookup_only
    real_addresses.each do |email|
      assert EmailMxOnly.new(:address => email).valid?, 'Should validate.'
    end
  end
  
  def test_email_address_with_invalid_domains
    %w[carsten@invalid.com joe_smith@invalid.ca i_am@surely-not-valid.net].each do |email|
      assert !EmailInvalidDomains.new(:address => email).valid?, 'Should not validate.'
    end
  end
  
  def test_blank_email_addresses
    assert Email.new(:address => '').valid?, 'Should pass validation.'
  end
  
  def test_nil_email_addresses
    assert Email.new(:address => nil).valid?, 'Should pass validation.'
  end
  
  def test_default_timeout_behavior
    assert EmailTimeout.new(:address => 'fake@fake1fake2nowhere3.ca').valid?, 'Should pass validation on timeout.'
  end
  
  def test_fail_on_timeout_behavior
    assert !EmailFailOnTimeout.new(:address => 'fake@fake1fake2nowhere3.ca').valid?, 'Should fail validation on timeout.'
  end
  
end