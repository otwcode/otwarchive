require File.dirname(__FILE__) + '/../test_helper'

class WorkTest < ActiveSupport::TestCase
  # Test associations
  #   has_many :chapters, :dependent => :destroy
  def test_has_many_chapters
    work = create_work
    assert chapter = work.chapters.first
    chapter2 = create_chapter(:work => work, :authors => work.pseuds)
    Work.find(work.id).destroy
    assert_raises(ActiveRecord::RecordNotFound) { Chapter.find(chapter.id) }
    assert_raises(ActiveRecord::RecordNotFound) { Chapter.find(chapter2.id) }
  end
  #   has_one :metadata, :as => :described, :dependent => :destroy
  def test_metadata
    meta = create_metadata
    work = create_work(:metadata => meta)
    new_title = random_phrase
    work.metadata.title=new_title
    work.save
    assert_equal new_title, work.metadata.title
    Work.find(work.id).destroy
    assert_raises(ActiveRecord::RecordNotFound) { Metadata.find(meta.id) }
  end
  # belongs_to :language
  # TODO test_belongs_to_language
   
  # Test before and after 
  # before_save :validate_authors
  # before_save :set_language 
  def test_before_save
    Locale.set 'en'
    pseud = create_pseud
    chapter = new_chapter(:authors => [pseud])
    work = new_work(:authors => [], :chapters => [chapter])
    assert !work.save
    work.authors = [pseud]
    assert work.save
    assert_equal [pseud], Work.find(work.id).pseuds
    assert_equal work.language, Locale.active.language  #English
    
    # setting a work language that doesn't match the locale shouldn't get overwritten
    language = create_language(:id => 1556, :iso_639_1 => 'de', :english_name => 'German', :native_name => 'Deutsch')
    work.language = language
    work.save
    assert_equal language, Work.find(work.id).language    
    assert_not_equal Locale.active.language, Work.find(work.id).language
  end
  # TODO test after_save :save_creatorships
  # TODO test after_update :save_associated, :save_creatorships
  
  # Test methods
  def test_find_all_comments
    pseud = create_pseud
    chapter1 = new_chapter
    work = create_work(:chapters => [chapter1])
    chapter2 = create_chapter(:work => work, :authors => work.pseuds)
    chapter3 = create_chapter(:work => work, :authors => work.pseuds)
    comment1 = new_comment(:commentable_id => chapter1.id, :email => '', :name => '', :pseud_id => pseud.id)
    comment1.set_and_save
    comment2 = new_comment(:commentable_id => chapter2.id, :email => '', :name => '', :pseud_id => pseud.id)
    comment2.set_and_save
    comment3 = new_comment(:commentable_id => chapter3.id, :email => '', :name => '', :pseud_id => pseud.id)
    comment3.set_and_save
    assert_equal [comment1, comment2, comment3], Work.find(work.id).find_all_comments 
  end
  def test_number_of_chapters
    work = create_work
    assert 1, work.number_of_chapters
    chapter2 = create_chapter(:work => work, :authors => work.pseuds)
    assert 2, work.number_of_chapters
    chapter3 = create_chapter(:work => work, :authors => work.pseuds)
    assert 3, chapter3.position
    assert 3, work.number_of_chapters
    chapter2.destroy
    assert 2, work.number_of_chapters
    assert 2, chapter3.position
  end 
  def test_number_of_posted_chapters
    # TODO test_last_chapter
  end
  def test_last_chapter
    # TODO test_last_chapter
  end
  def test_adjust_chapters
    # TODO test_adjust_chapters
  end
  def test_update_major_version
    # TODO test_update_major_version
  end
  def test_update_minor_version
    # TODO test_update_minor_version
  end 
  def test_chaptered
    work = create_work(:expected_number_of_chapters => 1)
    assert !work.chaptered?
    work.expected_number_of_chapters = nil
    assert work.chaptered?
    work.expected_number_of_chapters = 42
    assert work.chaptered?
  end
  def test_multipart
    # TODO test_multipart
  end
  def test_wip
    work = create_work
    # default is complete one-shot
    assert work.is_complete
    assert !work.is_wip
    # author marks it as wip, but doesn't give expected chapters
    work.wip_length = "?"
    assert work.is_wip
    assert !work.is_complete
    assert_equal nil, work.expected_number_of_chapters
    # author decides on two chapters
    work.wip_length = 2
    work.save
    assert work.is_wip
    assert !work.is_complete
    assert_equal 2, work.expected_number_of_chapters
    # author creates the second chapter
    create_chapter(:work => work, :authors => work.pseuds)
    work.reload
    assert work.is_complete
    assert !work.is_wip
    # author tries to enter invalid # of chapters
    work.wip_length = 1
    assert work.is_wip
    assert !work.is_complete
    assert_equal nil, work.expected_number_of_chapters
  end 
  def test_wip_length 
    work = create_work(:expected_number_of_chapters => 1)
    assert_equal 1, work.wip_length
    work.expected_number_of_chapters = nil
    assert_equal "?", work.wip_length  
  end
  
  # FIXME didn't create methods for the following, because they could/should be private
  # validate
  # set_language
  # metadata_attributes=
  # chapter_attributes=
  # author_attributes=
  # validate_authors
  # save_creatorships
  # save_associated
  # set_initial_version  
end
