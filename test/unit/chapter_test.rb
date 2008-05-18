require File.dirname(__FILE__) + '/../test_helper'

class ChapterTest < ActiveSupport::TestCase
  def test_create_default_chapter
    assert chapter = create_chapter
    assert_nil chapter.metadata
  end
  def test_create_chapter_with_metadata
    new_meta = create_metadata
    assert chapter = create_chapter(:metadata => new_meta)
    assert_equal chapter.metadata, new_meta
  end
  def test_create_chapter_with_bad_metadata
    meta = new_metadata(:title => "")
    chapter = new_chapter(:metadata => meta)
    assert !chapter.save
  end
  def test_update_chapter_metadata
    original_meta = create_metadata
    assert chapter = create_chapter(:metadata => original_meta)
    new_title = random_phrase
    original_meta.title=new_title
    assert chapter.save
    assert_equal chapter.metadata.title, new_title
  end
  def test_create_chapter_without_content
    bad_chapter = new_chapter(:content => "")
    assert !bad_chapter.save
  end
  def test_create_chapter_smallest    
    assert create_chapter(:content => String.random(1))
  end
  def test_create_chapter_largest
    assert create_chapter(:content => String.random(16777215))
  end
  def test_create_chapter_too_long
    bad_chapter = new_chapter(:content => String.random(16777216))
    assert !bad_chapter.save    
  end
  def test_create_single_chapter_in_work
    work = create_work
    assert_nil work.number_of_chapters
    chapter = create_chapter(:work => work)
    assert_equal [chapter], work.chapters.find(:all)
  end
  def test_add_new_chapters_in_work
    work = create_work    
    (1..10).each do |i| 
      chapter = create_chapter(:work => work)
      assert_equal i, chapter.position
      assert_equal i, work.number_of_chapters
      assert_equal chapter, work.chapters.find_by_position(i)
    end
  end
  def test_add_single_comment_to_chapter
    chapter = create_chapter
    comment = create_comment
    chapter.comments << [comment]
    assert_equal Chapter.find(chapter.id).comments.first, comment
  end
  def test_add_new_comment_to_chapter
    chapter = create_chapter
    (1..10).each do |i|
      comment = create_comment
      chapter.comments << [comment]
      assert_equal Chapter.find(chapter.id).comments.size, i
    end
  end
end
