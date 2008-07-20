require File.dirname(__FILE__) + '/../test_helper'

class ChapterTest < ActiveSupport::TestCase
  context "a Chapter" do
    setup do
      @pseud1 = create_pseud
      @chapter1 = new_chapter
      @work = create_work(:chapters => [@chapter1], :authors => [@pseud1])
    end
    should_belong_to :work
    should_require_attributes :content
    should_ensure_length_in_range :content, (1..16777215)
    should_ensure_length_in_range :title, (ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX)
    should_ensure_length_in_range :summary, (0..ArchiveConfig.SUMMARY_MAX)
    should_ensure_length_in_range :notes, (0..ArchiveConfig.NOTES_MAX)

    should "not able to remove the only author" do
        @chapter1.pseuds -= @work.pseuds
        assert !@chapter1.save
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
        @chapter2 = new_chapter(:work => @work, :authors => [])
        assert !@chapter2.save
      end
    end

    context "whose work gets a new chapter" do
      setup do
        assert @chapter2 = create_chapter(:work => @work, :authors => @work.pseuds)
      end
      should "know it is not the only chapter" do
        assert !@chapter1.is_only_chapter?
      end
      should "set the new chapter to position 2" do        
        assert_equal 2, @chapter2.position
      end
      should "be able to change its position" do
        @chapter1.move_to 2
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
          assert @chapter1.work.pseuds.include?(@pseud1)
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
        assert @chapter1.find_all_comments.include?(@comment)
      end
      should "count that comment" do
        assert_equal 1, @chapter1.count_all_comments
      end
    end

  end

end
