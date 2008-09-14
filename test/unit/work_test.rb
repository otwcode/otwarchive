require File.dirname(__FILE__) + '/../test_helper'

class WorkTest < ActiveSupport::TestCase

  context "a work" do
    setup do
      assert @work = create_work
    end
    should_have_many :chapters, :serial_works, :series, :related_works, :bookmarks, :taggings, :pseuds
    should_require_attributes :title
    should_ensure_length_in_range :title, 3..255, :short_message => /must be at least/
    should_ensure_length_in_range :notes, 0..2500, :long_message => /must be less/
    should_ensure_length_in_range :summary, 0..1250, :long_message => /must be less/
    should_belong_to :language
    should "have an author" do
      work = new_work(:authors => [])
      assert !work.save
      assert_contains work.errors.on(:base), /must have at least one author/
    end
    should_eventually "have a valid author" do
    end

    context "which has been posted" do
      setup do
        @work.update_attribute("posted", true)
      end
      should "be visible" do
        assert @work.visible
      end
      should "be visible en group" do
        assert Work.visible.include?(@work)
      end

      context "which is restricted" do
        setup do
          @work.restricted = true
          @work.save
        end
        should "not be visible by default" do
          assert !@work.visible
        end
        should "be visible to a user" do
          assert @work.visible(create_user)
        end
      end
    end

    context "with a comment on a chapter" do
      setup do
        @comment = create_comment(:commentable => @work.chapters.first)
      end
      should "find that comment" do
        assert @work.find_all_comments.include?(@comment)
      end
    end

    context "with a non-adult tag" do
      setup do
        @tagna = create_tag(:adult => false)
        @work.update_attribute('default', @tagna.name)
      end
      should "not be marked adult" do
        assert !@work.adult_content?
      end

      context "and an adult tag" do
        setup do
          @taga = create_tag(:adult => true)
          @work.update_attribute('default', @taga.name + ', ' + @tagna.name)
        end
        should "be marked adult" do
          assert @work.adult_content?
        end
      end
    end

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
  def test_chaptered
    work = create_work(:expected_number_of_chapters => 1)
    assert !work.chaptered?
    work.expected_number_of_chapters = nil
    assert work.chaptered?
    work.expected_number_of_chapters = 42
    assert work.chaptered?
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
end
