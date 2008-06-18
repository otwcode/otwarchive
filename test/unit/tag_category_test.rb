require File.dirname(__FILE__) + '/../test_helper'

class TagCategoryTest < ActiveSupport::TestCase
  def test_official
    # test non-official category
    category = create_tag_category
    assert !TagCategory.official.include?(category)
    category = create_tag_category(:official => true)
    assert TagCategory.official.include?(category)
    # TODO test sort
  end
  def test_official_tags
    category = create_tag_category
    tag = create_tag(:tag_category => category, :canonical => true)
    assert_equal Array(tag), TagCategory.official_tags(category.name)
    tag2 = create_tag(:tag_category => category, :canonical => false)
    assert_equal Array(tag), TagCategory.official_tags(category.name)
  end
end
