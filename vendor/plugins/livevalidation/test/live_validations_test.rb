require 'test/unit'
require 'rubygems'
require 'active_record'
require File.dirname(__FILE__) + '/../lib/live_validations'
require File.dirname(__FILE__) + '/../test/resource'

class LiveValidationTest < Test::Unit::TestCase
  
  def setup
    Resource.class_eval do # reset live validations
      @live_validations = {}
    end
  end

  def test_live_validations_accessor
    assert_kind_of(Hash, Resource.live_validations)
  end
  
  def test_without_validations
    assert_equal({}, Resource.live_validations)
  end
  
  def test_without_ok_message
    Resource.class_eval do
      validates_presence_of :name, :message => "can't be blank"
    end
    assert_equal("", Resource.live_validations[:name][:presence][:validMessage])
  end

  def test_with_ok_message
    Resource.class_eval do
      validates_presence_of :name, :message => "can't be blank", :validMessage => 'thank you!'
    end
    assert_equal("thank you!", Resource.live_validations[:name][:presence][:validMessage])
  end
    
  def test_presence
    Resource.class_eval do
      validates_presence_of :name, :message => "can't be blank"
    end
    assert_equal("can't be blank", Resource.live_validations[:name][:presence][:failureMessage])
  end
  
  def test_presence_more_than_one_attribute
    Resource.class_eval do
      validates_presence_of :name, :amount, :message => "can't be blank"
    end
    assert_equal("can't be blank", Resource.live_validations[:name][:presence][:failureMessage])
    assert_equal("can't be blank", Resource.live_validations[:amount][:presence][:failureMessage])
  end
  
  def test_numericality
    Resource.class_eval do
      validates_numericality_of :amount, :message => "isn't a valid number"
    end
    assert_equal("isn't a valid number", Resource.live_validations[:amount][:numericality][:notANumberMessage])
    assert(!Resource.live_validations[:amount][:numericality][:onlyInteger])
  end
  
  def test_numericality_only_integer
    Resource.class_eval do
      validates_numericality_of :amount, :only_integer => true, :message => "isn't an integer number"
    end
    assert_equal("isn't an integer number", Resource.live_validations[:amount][:numericality][:notAnIntegerMessage])
    assert(Resource.live_validations[:amount][:numericality][:onlyInteger])
  end

  def test_format
    Resource.class_eval do
      validates_format_of :name, :with => /^\w+$/, :message => "only letters are accepted"
    end
    assert_equal("only letters are accepted", Resource.live_validations[:name][:format][:failureMessage])
    assert_equal(/^\w+$/, Resource.live_validations[:name][:format][:pattern])
  end
  
  def test_length_max
    Resource.class_eval do
      validates_length_of :name, :maximum => 10, :message => "must be under 10 characters long"
    end
    assert_equal("must be under 10 characters long", Resource.live_validations[:name][:length][:failureMessage])
    assert_equal(10, Resource.live_validations[:name][:length][:maximum])
  end
  
  def test_length_min
    Resource.class_eval do
      validates_length_of :name, :minimum => 4, :message => "must be more than 4 characters long"
    end
    assert_equal("must be more than 4 characters long", Resource.live_validations[:name][:length][:failureMessage])
    assert_equal(4, Resource.live_validations[:name][:length][:minimum])
  end
  
  def test_length_range
    Resource.class_eval do
      validates_length_of :name, :in => 4..10, :message => "must be between 4 and 10 characters long"
    end
    assert_equal("must be between 4 and 10 characters long", Resource.live_validations[:name][:length][:failureMessage])
    assert_equal(4, Resource.live_validations[:name][:length][:minimum])
    assert_equal(10, Resource.live_validations[:name][:length][:maximum])
    assert_nil(Resource.live_validations[:name][:length][:in])
  end
  
  def test_length_exact
    Resource.class_eval do
      validates_length_of :name, :is => 5, :message => "must be 5 characters long"
    end
    assert_equal("must be 5 characters long", Resource.live_validations[:name][:length][:failureMessage])
    assert_equal(5, Resource.live_validations[:name][:length][:is])
  end
  
  def test_acceptance
    Resource.class_eval do
      validates_acceptance_of :conditions, :message => "you must accept conditions"
    end
    assert_equal("you must accept conditions", Resource.live_validations[:conditions][:acceptance][:failureMessage])
  end
  
  def test_confirmation
    Resource.class_eval do
      validates_confirmation_of :name, :message => "doesn't match"
    end
    assert_equal("doesn't match", Resource.live_validations[:name][:confirmation][:failureMessage])
  end
  
end
