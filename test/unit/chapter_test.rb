require File.dirname(__FILE__) + '/../test_helper'

class ChapterTest < ActiveSupport::TestCase
  # Test validations
  def test_presence_of_content_fails
    chapter = new_chapter(:content => "")
    work = new_work(:chapters => [chapter])
    assert !work.save
  end
  def test_presence_of_content_passes    
    chapter = new_chapter(:content => String.random(1))
    work = new_work(:chapters => [chapter])
    assert work.save
  end
  def test_length_of_content
    long_string = "aa"
    (1..23).each {|i| long_string << long_string }
    chapter = new_chapter(:content => long_string)
    work = new_work(:chapters => [chapter])
    assert !work.save
    chapter = new_chapter(:content => long_string.chop)
    work = new_work(:chapters => [chapter])
    assert work.save
  end

  # Test associations
  def test_belongs_to_work
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    assert_equal work, chapter.work
  end
  def test_has_one_metadata
    metadata = create_metadata
    chapter = new_chapter(:metadata => metadata)
    work = create_work(:chapters => [chapter])
    assert_equal metadata, chapter.metadata
  end

  # Test acts_as
  # commentable: CommentableEntity methods find_all_comments & count_all_comments
  def test_acts_as_commentable
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    comment = new_comment(:commentable_id => chapter.id)
    comment.set_and_save
    assert chapter.find_all_comments.include?(comment)
    assert_equal 1, chapter.count_all_comments
  end

  # Test before and after
  def test_before_save_set_position
    work = create_work
    chapter2 = new_chapter(:work_id => work.id)
    assert_equal 1, chapter2.position
    chapter2.save
    assert_equal 2, chapter2.position
  end
  def test_before_save_validate_authors
    work = create_work
    chapter = new_chapter(:work_id => work.id, :authors => [])
    assert !chapter.save
    pseud = create_pseud
    chapter.authors = [pseud]
    assert chapter.save
  end
  def test_after_update_save_associated
    original_meta = create_metadata
    chapter = new_chapter(:metadata => original_meta)
    work = create_work(:chapters => [chapter])
    chapter = Chapter.find(chapter.id)
    new_title = random_phrase
    chapter.metadata.title=new_title
    chapter.save
    assert_equal new_title, Chapter.find(chapter.id).metadata.title
  end
  def test_after_create_save_creatorships
    pseud = create_pseud
    work = create_work
    chapter = create_chapter(:work_id => work.id, :authors => [pseud])
    assert_equal [pseud], Chapter.find(chapter.id).pseuds
  end
  def test_after_update_save_creatorships
    # TODO tests for save_creatorship
  end

  # Test methods
  def test_is_only_chapter
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    assert chapter.is_only_chapter?    
    chapter2 = create_chapter(:work_id => work.id)
    assert !Chapter.find(chapter.id).is_only_chapter?
    chapter.destroy
    assert Chapter.find(chapter2.id).is_only_chapter?
  end
  # FIXME didn't create methods for the following, because they could/should be private
    # author_attributes=
    # validate_authors
    # save_creatorships
    # metadata_attributes=
    # save_associated
end
