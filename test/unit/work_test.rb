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

  context "a work with a tag and a work without a tag" do
    setup do
      @tagged_work = create_work
      @untagged_work = create_work
      @tag = create_tag
      @tagged_work.tags << @tag
      @tagged_work.save
    end
    should "be returned/not returned by with_any_tags, respectively" do
      assert Work.with_any_tags([@tag]).include?(@tagged_work)
      assert !Work.with_any_tags([@tag]).include?(@untagged_work)
    end
    should "not/should be returned by no_tags, respectively" do
      works_without_tags = Work.no_tags(@tag.tag_category)
      assert !works_without_tags.include?(@tagged_work)
      assert works_without_tags.include?(@untagged_work)
    end

    context "and a work with two tags" do
      setup do
        @two_tagged = create_work
        @tag2 = create_tag
        @two_tagged.tags << @tag
        @two_tagged.tags << @tag2
        @two_tagged.save
      end

      context "retrieved by with_all_tags" do
        setup do
          @all_retrieved = Work.with_all_tags([@tag, @tag2])
        end
        should "only include the work with both tags" do
          assert @all_retrieved.include?(@two_tagged)
          assert !@all_retrieved.include?(@tagged_work)
          assert !@all_retrieved.include?(@untagged_work)
        end
      end

      context "retrieved by with_any_tags" do
        setup do
          @all_retrieved = Work.with_any_tags([@tag, @tag2])
        end
        should "include both tagged works" do
          assert @all_retrieved.include?(@two_tagged)
          assert @all_retrieved.include?(@tagged_work)
          assert !@all_retrieved.include?(@untagged_work)
        end
      end
    end
      
    context "retrieved by with_any_tags" do
      setup do
        @retrieved_work = Work.with_any_tags([@tag]).first
      end
      should "be equal to the original work" do
        assert @retrieved_work == @tagged_work
      end
      should "return true for having that tag" do
        assert @retrieved_work.tags.include?(@tag)
      end
    end

    context "that are posted and not restricted/hidden" do
      setup do
        @tagged_work.update_attribute('posted', true)
        @untagged_work.update_attribute('posted', true)
      end
      should "be returned/not returned by visible.with_any_tags" do
        assert Work.visible.with_any_tags([@tag]).include?(@tagged_work)
        assert !Work.visible.with_any_tags([@tag]).include?(@untagged_work)
      end
    end    
  end

  context "two works owned by different users" do
    setup do
      @work1 = create_work
      @work2 = create_work
    end
    should "only be returned by owned_by on their own owner" do
      owned1 = Work.owned_by(@work1.pseuds.first.user)
      owned2 = Work.owned_by(@work2.pseuds.first.user)
      assert owned1.include?(@work1)
      assert !owned1.include?(@work2)
      assert owned2.include?(@work2)
      assert !owned2.include?(@work1)
    end
    context "with a tag" do
      setup do
        @tag = create_tag
        @work1.tags << @tag
        @work2.tags << @tag
        @work1.save
        @work2.save
      end
      should "be returned by with_any_tags and owned_by chained" do
        owned_with_tag = Work.owned_by_conditions(@work1.pseuds.first.user).with_any_tags([@tag])
        assert owned_with_tag.include?(@work1)
        assert !owned_with_tag.include?(@work2)
        owned_with_tag = Work.owned_by_conditions(@work2.pseuds.first.user).with_any_tags([@tag])
        assert owned_with_tag.include?(@work2)
        assert !owned_with_tag.include?(@work1)
      end
      context "and having been posted" do
        setup do
          @work1.update_attribute("posted", true)
          @work2.update_attribute("posted", true)
        end
        should "be returned by owned_by chained with visible and with tags" do
          owned_visible_tagged = Work.owned_by_conditions(@work1.pseuds.first.user).visible.with_any_tags([@tag])
          assert owned_visible_tagged.include?(@work1)
          assert !owned_visible_tagged.include?(@work2)
          owned_visible_tagged = Work.visible.owned_by_conditions(@work1.pseuds.first.user).with_any_tags([@tag])
          assert owned_visible_tagged.include?(@work1)
          assert !owned_visible_tagged.include?(@work2)
        end
      end
    end
  end 

  context "multiple works with tags" do
    setup do
      @works = []
      @tag = create_tag
      title = 9

      10.times do 
        @works << create_work(:title => (title.to_s + title.to_s + title.to_s))
        title = title - 1
      end

      @works.each do |w|
        w.update_attribute('posted', true)
        w.update_attribute('default', @tag.name)
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
      
    should "be returned in the right order when retrived with with_any_tags" do
      @ordered_works = Work.with_any_tags([@tag]).ordered('title', 'ASC')
      assert @ordered_works[0] = @works[9]
      assert @ordered_works[9] = @works[0]
    end

    should "be returned in the right order when retrived with visible" do
      @ordered_works = Work.visible.ordered('title', 'ASC')
      assert @ordered_works[0] = @works[9]
      assert @ordered_works[9] = @works[0]
    end
      
    should "be returned in the right order when retrived with visible_with_any_tags" do
      @ordered_works = Work.visible.with_any_tags([@tag]).ordered('title', 'ASC')
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
