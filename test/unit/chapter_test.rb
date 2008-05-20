require File.dirname(__FILE__) + '/../test_helper'

class ChapterTest < ActiveSupport::TestCase
  def test_create_single_chapter   #after_save adds authors to the work, so must create work as well
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    assert_equal work.chapters.first, chapter
  end
  def test_update_chapter_metadata
    original_meta = create_metadata
    chapter = new_chapter(:metadata => original_meta)
    work = create_work(:chapters => [chapter])
    new_title = random_phrase
    work.chapters.first.metadata.title=new_title
    work.save
    assert_equal work.chapters.first.metadata.title, new_title
  end
  def test_create_chapter_without_content
    chapter = new_chapter(:content => "")
    work = new_work(:chapters => [chapter])
    assert !work.save
  end
  def test_create_chapter_smallest    
    assert chapter = new_chapter(:content => String.random(1))
    assert work = create_work(:chapters => [chapter])
    assert_equal work.chapters.first, chapter
  end
  def test_create_chapter_largest
    long_string = "aa"
    (1..23).each {|i| long_string << long_string }
    chapter = new_chapter(:content => long_string)
    work = new_work(:chapters => [chapter])
    assert !work.save
    chapter = new_chapter(:content => long_string.chop)
    work = new_work(:chapters => [chapter])
    assert work.save
  end
  def test_add_new_chapters_in_work
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    (2..10).each do |i| 
      chapter = create_chapter(:work => work)
      assert_equal i, chapter.position
      assert_equal i, work.number_of_chapters
      assert_equal chapter, work.chapters.find_by_position(i)
    end
  end
  def test_add_single_comment_to_chapter
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    comment = create_comment
    chapter.comments << [comment]
    assert chapter.save
    assert_equal chapter.comments.first, comment
  end
  def test_add_new_comment_to_chapter
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    (1..10).each do |i|
      comment = create_comment
      chapter.comments << [comment]
      chapter.save
      assert_equal chapter.comments.size, i
    end
  end
end
