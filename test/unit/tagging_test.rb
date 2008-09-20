require File.dirname(__FILE__) + '/../test_helper'

# the tests here are for the tagging model, and the tagging_extensions library

class TaggingTest < ActiveSupport::TestCase
  context "a tagging" do
    setup do
      @tag_category = create_tag_category
      @tag1 = create_tag(:tag_category => @tag_category)
      @tagging = create_tagging(:tag => @tag1)
    end
    should_belong_to :tag, :taggable
    should_require_attributes :tag, :taggable
    should "be able to find_by_category" do
      assert Tagging.find_by_category(@tag_category).include?(@tagging)
    end
    should "be able to find_by_tag" do
      assert Tagging.find_by_tag(@tag1).include?(@tagging)
    end
  end

  def test_tags
    tag = create_tag(:banned => true)
    work = create_work
    tagging = create_tagging(:taggable => work, :tag => tag)
    work.reload
    assert_equal Array(tag), work.taggings.map(&:tag)
    assert_equal [], work.tags.valid           # no category, not valid
    tag = create_tag(:banned => false)
    tagging = create_tagging(:taggable => work, :tag => tag)
    work.reload
    assert_equal Array(tag), work.tags.valid   # no category, valid
  end
  def test_tags_with_category
    category = create_tag_category
    tag = create_tag(:tag_category => category)
    work = create_work
    tagging = create_tagging(:taggable => work, :tag => tag)  
    work.reload
    assert_equal Array(tag), work.tags.by_category(category).valid  # category, valid
    bad_tag = create_tag(:banned => true)
    tagging = create_tagging(:taggable => work, :tag => bad_tag)    
    assert_equal Array(tag), work.tags.by_category(category).valid  # category, not valid
  end
  def test_tags_with_bad_category
    work = create_work
    tag = create_tag
    tagging = create_tagging(:taggable => work, :tag => tag)   
    assert work.tags
    #assert !work.tags.by_category('bad category name')
  end
  def test_tag_string
    work = create_work
    tag = create_tag(:name => 'a comes first')
    tagging = create_tagging(:taggable => work, :tag => tag) 
    work.reload
    assert_equal tag.name, work.tag_string
    tag2 = create_tag(:name => 'b comes second')
    tagging = create_tagging(:taggable => work, :tag => tag2) 
    work.reload
    assert_equal "a comes first, b comes second", work.tag_string
    tag3 = create_tag(:name => 'an comes second')
    tagging = create_tagging(:taggable => work, :tag => tag3) 
    work.reload
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
    assert_not_equal work.tag_string(category1), work.tag_string(category2)
    assert_equal tag1.name, work.tag_string(category1)
  end
  def test_tag_with
    work = create_work
    category = create_tag_category
    # new tags
    work.tag_with(category.name.to_sym => "a new tag")
    work.reload
    assert_equal 'a new tag', work.tag_string
    assert_equal category, Tag.find_by_name('a new tag').tag_category
    # replace tags
    tag = create_tag(:tag_category => category)
    work.tag_with(category.name.to_sym => tag.name)
    work.reload
    assert_equal Array(tag), work.tags.valid
    # different category won't wipe out first
    category2 = create_tag_category
    tag2 = create_tag(:tag_category => category2)
    work.tag_with(category2.name.to_sym => tag2.name)
    assert_equal Array(tag), work.tags.by_category(category).valid
    assert_equal Array(tag2), work.tags.by_category(category2).valid
  end
  def test_tag_with_fails
    # category must exist
    work = create_work
    assert !work.tag_with(:not_a_category => random_phrase)
  end
end
