require File.dirname(__FILE__) + '/../test_helper'

class WorkTest < ActiveSupport::TestCase

  context "a work" do
    setup do
      assert @work = create_work
    end
    should_have_many :chapters, :serial_works, :series, :related_works, :bookmarks, :taggings, :pseuds
    should_require_attributes :title
    should_ensure_length_in_range :title, ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX, :short_message => /must be at least/, :long_message => /must be less/
    should_ensure_length_in_range :notes, 0..ArchiveConfig.NOTES_MAX, :long_message => /must be less/
    should_ensure_length_in_range :summary, 0..ArchiveConfig.SUMMARY_MAX, :long_message => /must be less/
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
        @work.add_default_tags
        @work.update_attribute("posted", true)
      end
      should "be visible" do
        assert @work.visible?
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
      should "not be visible en group" do
        assert !Work.visible.include?(@work)
      end
      end
      
      context "which is hidden by an admin" do
        setup do
          @work.update_attribute("hidden_by_admin", true)
        end
        should "not be visible by default" do
          assert !@work.visible
        end
        should "not be visible to a random user" do
          assert !@work.visible(create_user)
        end
        should "be visible to an admin" do
          assert @work.visible(create_admin)
        end
        should "be visible to its owner" do
          assert @work.visible(@work.pseuds.first.user)
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
  end

  context "three works with common tags count 0, 1 , 2" do
    setup do
      @untagged_work = create_work
      @tagged_work = create_work
      @tag = create_freeform(:canonical => true)
      @tagged_work.freeform_string = @tag.name
      @tag2 = create_freeform(:canonical => true)
      @two_tagged = create_work
      @two_tagged.freeform_string = @tag.name + ", " + @tag2.name
    end
    should "only include both works with tags when retrieved with the shared tag id" do
      assert_equal [@tagged_work, @two_tagged], Work.with_all_tag_ids([@tag.id])
    end      
    should "only include the work with both tags when retrieved with both tag ids" do
      assert_equal [@two_tagged], Work.with_all_tag_ids([@tag.id, @tag2.id])
    end      
  end

  context "two works owned by different users" do
    setup do
      user1 = create_user
      user2 = create_user
      @work1 = create_work(:authors => [user1.default_pseud])
      @work2 = create_work(:authors => [user2.default_pseud])
      @work1.add_default_tags
      @work2.add_default_tags
    end
    should "only be returned by owned_by on their own owner" do
      user1 = @work1.pseuds.first.user
      user2 = @work2.pseuds.first.user
      assert_not_equal user1, user2
      assert_equal [@work1], Work.owned_by(user1)
      assert_equal [@work2], Work.owned_by(user2)
    end
    context "with a common tag" do
      setup do
        @tag = create_freeform(:canonical => true)
        @work1.freeform_string = @tag.name
        @work2.freeform_string = @tag.name
      end
      should "be returned by with_all_tag_ids and owned_by chained" do
        assert_equal [@work1], Work.with_all_tag_ids([@tag.id]).owned_by(@work1.pseuds.first.user)
      end
      should "not be returned by with_all_tag_ids and owned_by and visible chained" do
        assert_equal [], Work.visible.owned_by(@work1.pseuds.first.user).with_all_tag_ids([@tag.id])
      end
      context "and visible" do
        setup do
          @work1.update_attribute("posted", true)
        end
        should "be returned by owned_by chained with visible and with tags" do
          assert_equal [@work1], Work.visible.owned_by(@work1.pseuds.first.user).with_all_tag_ids([@tag.id])
        end
      end
    end
  end 

  context "multiple works with tags" do
    setup do
      @works = []
      @tag = create_freeform
      title = 9

      10.times do 
        @works << create_work(:title => (title.to_s + title.to_s + title.to_s))
        title = title - 1
      end

      @works.each do |w|
        w.update_attribute('posted', true)
        w.freeform_string = @tag.name
      end

    end
    
    should "be returned in reverse order by title" do
      @ordered_works = Work.ordered('title', 'ASC')
      assert @ordered_works[0] = @works[9]
      assert @ordered_works[9] = @works[0]
    end
    
    should "be returned in same order by date created" do
      @ordered_works = Work.ordered('created_at', 'ASC')
      assert @ordered_works[0] = @works[0]
      assert @ordered_works[9] = @works[9]
    end
      
    should "be returned in the right order when retrived with with_all_tag_ids" do
      @ordered_works = Work.with_all_tag_ids([@tag.id]).ordered('title', 'ASC')
      assert @ordered_works[0] = @works[9]
      assert @ordered_works[9] = @works[0]
    end

    should "be returned in the right order when retrived with visible" do
      @ordered_works = Work.visible.ordered('title', 'ASC')
      assert @ordered_works[0] = @works[9]
      assert @ordered_works[9] = @works[0]
    end
      
    should "be returned in the right order when retrived with visible and with_all_tag_ids" do
      @ordered_works = Work.visible.with_all_tag_ids([@tag.id]).ordered('title', 'ASC')
      assert @ordered_works[0] = @works[9]
      assert @ordered_works[9] = @works[0]
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
    work.add_default_tags
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
  
  def test_no_leading_spaces_in_title
    title = "should have no leading space"
    title_with_space = ' ' + title
    work = create_work(:title => title_with_space)
    assert_equal title, work.title
    assert work.valid?
    
    title = "    "
    work.title = title
    assert !work.valid?
  end

end
