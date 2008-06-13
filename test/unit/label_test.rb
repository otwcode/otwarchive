require File.dirname(__FILE__) + '/../test_helper'

class LabelTest < ActiveSupport::TestCase
  def test_validations_fail
    ['a'*43, 'label with : in it', 'label with , in it'].each do |name|
      label = Label.new(:name => name)
      assert !label.save
     end
  end
  def test_validations_pass
    ['a'*42, 'label with / in it', 'label with ! in it'].each do |name|
      label = Label.new(:name => name)
      assert label.save
     end
  end
  def test_before_save
    label = Label.create(:name => "  lots    of extra   spaces     ")
    assert_equal "lots of extra spaces", label.name
  end
  def test_find_popular
    assert_equal Label.find_by_name('characters'), Label.find_popular(:limit => 1)[0]
    assert_equal Label.find_by_name('Stargate SG-1'), 
                 Label.find_popular(:conditions => "taggings.tagger_type = 'Work'")[0]
  end
  def test_find_official
    assert_equal "Stargate Atlantis, Stargate SG-1, Torchwood",    
                 Label.find_official('fandoms').map(&:name).join(', ')
    assert_equal [Label.find(17)],
                 Label.find(:all).select{|t| t.is_character? } - Label.find_official('characters')
  end
  def test_freeform_resembles_and_parent
    label = create_label
    assert label.is_freeform?
    assert Label.find_freeform.include?(label)
    parent = create_label(:meta => 'parent')
    label.tags << parent
    assert label.child_of?(parent)
    assert !Label.find_freeform.include?(parent)
    sibling = create_label
    sibling.tags << parent
    label.resembles sibling
    assert sibling.is_freeform?
    assert sibling.resembles?(label)
  end
  def test_banned
    label = Label.find(11)
    assert label.is_banned?
  end
  def test_disambiguates
    jack = Label.find_by_name('jack')
    oneil = Label.find_by_name("Jack O'Neil")
    assert oneil.disambiguates?(jack)
  end
end