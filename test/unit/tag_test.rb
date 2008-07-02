require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  def test_validations_fail
    ['a'*43, 'tag with : in it', 'tag with , in it'].each do |name|
      tag = Tag.new(:name => name)
      assert !tag.save
     end
  end
  def test_validations_pass
    ['a'*42, 'tag with / in it', 'tag with ! in it'].each do |name|
      tag = Tag.new(:name => name, :tag_category_id => 1)
      assert tag.save
     end
  end
  def test_before_save
    tag = create_tag(:name => "  lots    of extra   spaces     ")
    assert_equal "lots of extra spaces", tag.name
  end
  def test_name_override
    name = "all lower-case/ugly"
    tag = create_tag(:name => name)
    tag.reload
    assert_equal name, tag.name
    tag.canonical = true
    assert_equal "All Lower-Case/Ugly", tag.name
    tag.canonical = false
    assert_equal name, tag.name
  end
  def test_tagees
    tag = create_tag
    work = create_work
    tagging = create_tagging(:taggable => work, :tag => tag)
    assert_equal Array(work), tag.tagees('works')
    bookmark = create_bookmark
    tagging = create_tagging(:taggable => bookmark, :tag => tag)
    assert_equal Array(bookmark), tag.tagees('bookmarks')
    new_tag = create_tag
    tagging = create_tagging(:taggable => new_tag, :tag => tag)
    assert_equal Array(new_tag), tag.tagees('tags')
    # order is tags, works, bookmarks....
    assert_equal Array[new_tag, work, bookmark], tag.tagees
    assert_equal 2, tag.tagees(['works', 'bookmarks']).size
  end
  def test_valid
    tag = create_tag
    assert tag.valid
    tag = create_tag(:banned => true)
    assert !tag.valid
  end
  def visible
    tag = create_tag
    assert !tag.visible
    tag = create_tag(:canonical => true)
    assert tag.visible
  end
end
