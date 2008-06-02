require File.dirname(__FILE__) + '/../test_helper'

class MetadataTest < ActiveSupport::TestCase
  
  # Test validations
  def test_validations_fail
    # validates_length_of :title, :maximum => 255
    string256 = "aa"
    (1..7).each {|i| string256 << string256 }
    meta = new_metadata(:title => string256)
    assert !meta.save
    meta.title = "aaa"
    assert meta.save
    # validates_length_of :summary, :maximum => 1250
    string1250 = ''
    (1..4).each {|i| string1250 << string256 }
    (1..113).each {|i| string1250 << 'aa' }    
    meta.summary = string1250 + 'a'
    assert !meta.save
    meta.summary = string1250
    assert meta.save
    # validates_length_of :notes, :maximum => 2500
    meta.notes = string1250 + string1250
    assert meta.save
    meta.notes = string1250 + string1250 + 'a'
    assert !meta.save
  end 

  # Test validataions for work associations
  def test_validations_fail_work
    meta = new_metadata(:title => '')
    work = new_work(:metadata => meta)
    assert !work.save
    work.metadata.title = '1'
    assert !work.save 
    work.metadata.title = '12'
    assert !work.save 
    work.metadata.title = '123'
    assert work.save 
  end
end
