require 'test_helper'

class ChapterTest < ActiveSupport::TestCase
  context "a Chapter" do
    setup do
      @pseud1 = create_pseud
      @chapter1 = new_chapter(:posted => true)
      @work = create_work(:chapters => [@chapter1], :authors => [@pseud1], :posted => true)
    end
    should_belong_to :work
    should_validate_presence_of :content
    should_ensure_length_in_range :content, (1..500000), :short_message => "can't be blank", :long_message => /cannot be more/
    should_ensure_length_in_range :title, (0..ArchiveConfig.TITLE_MAX), :long_message => /must be less/
    should_ensure_length_in_range :summary, (0..ArchiveConfig.SUMMARY_MAX), :long_message => /must be less/
    should_ensure_length_in_range :notes, (0..ArchiveConfig.NOTES_MAX), :long_message => /must be less/

    should "not able to remove the only author" do
        @chapter1.pseuds -= @work.pseuds
        assert !@chapter1.save
    end
    
    should "not be able to have a published_at date in the future" do
      @chapter1.published_at = random_future_date
      assert !@chapter1.save
    end
    
    context "without a published_at date" do
      should "be set to today's date" do
        @chapter1.published_at = nil
        @chapter1.save
        assert @chapter1.published_at == Date.today
      end
    end

    context "which is the first of a work" do
      should "be set to have the same authors as the work" do
        assert_equal @work.pseuds, @chapter1.pseuds
      end
      should "be set to position 1" do
        assert_equal 1, @chapter1.position
      end
      should "know it is the only chapter" do
        assert @chapter1.is_only_chapter?
      end
    end

    context "which is not the first" do
      should_eventually "get the works authors if not otherwise specified" do
        @chapter2 = create_chapter(:work => @work)
        assert_equal @work.pseuds, @chapter2.pseuds
      end
      should "get an error if the authors are empty" do
        @chapter2 = new_chapter(:work => @work, :authors => [], :position => 2)
        assert !@chapter2.save
      end
    end

    context "whose work gets a new chapter" do
      setup do
        assert @chapter2 = create_chapter(:work => @work, :authors => @work.pseuds, :position => 2, :posted => true)
      end
      should "know it is not the only chapter" do        
        assert !@chapter1.is_only_chapter?
      end
      should "set the new chapter to position 2" do
        assert_equal 2, @chapter2.position
      end
      should "be able to change its position" do
        @chapter1.insert_at 2
        assert_equal 2, @chapter1.position
        @chapter2.reload
        assert_equal 1, @chapter2.position
      end
    end

    context "with two authors" do
      setup do
        @pseud2 = create_pseud
        assert @chapter1.pseuds << @pseud2
      end
      context "removing the original author" do
        setup do
          @chapter1.pseuds -= Array(@pseud1)
        end
        should "leave the new author as the only author on the chapter" do
          assert_equal Array(@pseud2), @chapter1.pseuds
        end
        should "not remove the original author from the work" do
          assert_contains(@chapter1.work.pseuds, @pseud1)
        end
      end
      should "be able to remove the new author" do
        @chapter1.pseuds -= Array(@pseud2)
        assert_equal Array(@pseud1), @chapter1.pseuds
      end
      should "not be able to remove all the authors" do
        @chapter1.pseuds = []
        assert !@chapter1.save
      end
    end

    # commentable: CommentableEntity methods find_all_comments & count_all_comments
    context "with a comment" do
      setup do
        @comment = create_comment(:commentable => @chapter1)
      end
      should "find that comment" do
        assert_contains(@chapter1.find_all_comments, @comment)
      end
      should "count that comment" do
        assert_equal 1, @chapter1.count_all_comments
      end
    end

  end

  def test_no_leading_spaces_in_title
    title = "should have no leading space"
    title_with_space = ' ' + title
    chapter = create_chapter(:title => title_with_space)
    assert_equal title, chapter.title
    assert chapter.valid?

    title = "    "
    chapter.title = title
    assert chapter.valid?
    assert chapter.title.blank?
  end

end


