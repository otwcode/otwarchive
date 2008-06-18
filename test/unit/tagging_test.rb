require File.dirname(__FILE__) + '/../test_helper'

# the tests here are for the tagging model, and the tagging_extensions library

class TaggingTest < ActiveSupport::TestCase
  def test_tagees
    tag = create_tag
    tagged = create_tag
    tagging = create_tagging(:taggable => tagged, :tag => tag)
    assert_equal Array(tagged), tag.tagees
  end
  def test_find_by_category
    category = create_tag_category
    tag = create_tag(:tag_category => category)
    work = create_work
    tagging = create_tagging(:tag => tag, :taggable => work)
    assert_equal work.taggings, Tagging.find_by_category(category)
    # tag the work with a tag in a different category
    category2 = create_tag_category
    tag2 = create_tag(:tag_category => category2)
    tagging = create_tagging(:taggable => work, :tag => tag2)
    work.reload
    # the taggings should be different, but together should make up all the work's taggings
    assert_not_equal Tagging.find_by_category(category), Tagging.find_by_category(category2)
    assert_equal work.taggings, Tagging.find_by_category(category) + Tagging.find_by_category(category2)
  end
  def test_find_by_tag
    tag = create_tag
    work = create_work
    tagging = create_tagging(:tag => tag, :taggable => work)
    work.reload
    # work has one tagging, with this tag
    assert_equal work.taggings, work.taggings.find_by_tag(tag)
    tagging = create_tagging(:taggable => work)
    work.reload
    # work now has two taggings
    assert_not_equal work.taggings, work.taggings.find_by_tag(tag)
  end
  def test_tags
    tag = create_tag(:banned => true)
    work = create_work
    tagging = create_tagging(:taggable => work, :tag => tag)
    assert_equal Array(tag), work.taggings.map(&:tag)
    assert_equal [], work.tags           # no category, not valid
    tag = create_tag(:banned => false)
    tagging = create_tagging(:taggable => work, :tag => tag)
    assert_equal Array(tag), work.tags   # no category, valid
  end
  def test_tags_with_category
    category = create_tag_category
    tag = create_tag(:tag_category => category)
    work = create_work
    tagging = create_tagging(:taggable => work, :tag => tag)    
    assert_equal Array(tag), work.tags(category.name)  # category, valid
    bad_tag = create_tag(:banned => true)
    tagging = create_tagging(:taggable => work, :tag => bad_tag)    
    assert_equal Array(tag), work.tags(category.name)  # category, not valid
  end
  def test_tags_with_bad_category
    work = create_work
    tag = create_tag
    tagging = create_tagging(:taggable => work, :tag => tag)   
    assert work.tags
    assert !work.tags('bad category name')
  end
  def test_tag_string
    work = create_work
    tag = create_tag(:name => 'a comes first')
    tagging = create_tagging(:taggable => work, :tag => tag)   
    assert_equal tag.name, work.tag_string
    tag2 = create_tag(:name => 'b comes second')
    tagging = create_tagging(:taggable => work, :tag => tag2) 
    assert_equal "a comes first, b comes second", work.tag_string
    tag3 = create_tag(:name => 'an comes second')
    tagging = create_tagging(:taggable => work, :tag => tag3) 
    assert_equal "a comes first, an comes second, b comes second", work.tag_string
  end
  def test_tag_string_by_category
    work = create_work
    category1 = create_tag_category
    tag1 = create_tag(:tag_category => category1)
    category2 = create_tag_category
    tag2 = create_tag(:tag_category => category2)
    tagging = create_tagging(:taggable => work, :tag => tag1) 
    tagging = create_tagging(:taggable => work, :tag => tag2) 
    assert_not_equal work.tag_string(category1.name), work.tag_string(category2.name)
    assert_equal tag1.name, work.tag_string(category1.name)
  end
  def test_tag_with
    work = create_work
    category = create_tag_category
    # new tags
    work.tag_with(category.name.to_sym => "a new tag")
    assert_equal 'a new tag', work.tag_string
    assert_equal category, Tag.find_by_name('a new tag').tag_category
    # replace tags
    tag = create_tag(:tag_category => category)
    work.tag_with(category.name.to_sym => tag.name)
    assert_equal Array(tag), work.tags
    # different category won't wipe out first
    category2 = create_tag_category
    tag2 = create_tag(:tag_category => category2)
    work.tag_with(category2.name.to_sym => tag2.name)
    assert_equal Array(tag), work.tags(category.name)
    assert_equal Array(tag2), work.tags(category2.name)
  end
  def test_tag_with_fails
    # category must exist
    work = create_work
    assert !work.tag_with(:not_at_category => random_phrase)
    # tag must not have already been created in a different category
    category = create_tag_category
    tag = create_tag(:tag_category => category)
    category2 = create_tag_category
    assert !work.tag_with(category2.name.to_sym => tag.name)
  end
end
