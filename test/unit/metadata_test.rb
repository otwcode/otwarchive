require File.dirname(__FILE__) + '/../test_helper'

class MetadataTest < ActiveSupport::TestCase
  # Test validations
  def test_validations_fail
    # validates_presence_of :title
    meta = new_metadata(:title => '')
    assert !meta.save
    # validates_length_of :title
    meta.title = '1'
    assert !meta.save
    meta.title = '12'
    assert !meta.save
    string256 = "aa"
    (1..7).each {|i| string256 << string256 }
    meta.title = string256
    assert !meta.save
    meta.title = string256.chop
    assert meta.save
    # validates_length_of :summary
    string1250 = ''
    (1..4).each {|i| string1250 << string256 }
    (1..113).each {|i| string1250 << 'aa' }    
    meta.summary = string1250 + 'a'
    assert !meta.save
    meta.summary = string1250
    assert meta.save
    # validates_length_of :notes
    meta.notes = string1250 + string1250
    assert meta.save
    meta.notes = string1250 + string1250 + 'a'
    assert !meta.save
  end
  
  # Test associations
  def test_belongs_to_described
    # TODO belongs to described
  end
end
