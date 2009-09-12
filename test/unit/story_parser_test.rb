require File.dirname(__FILE__) + '/../test_helper'

class StoryParserTest < ActiveSupport::TestCase

  context "a storyparser" do
    setup do
      @storyparser = StoryParser.new
    end

    context "given a plaintext story" do
      setup do
        @text = random_chapter
      end
      should "create a new unposted work with the text as its content" do
        @work = @storyparser.parse_story(@text)
        assert !@work.posted
        assert @work.chapters.first.content == @text
      end
      context "with the title and summary in the text" do
        setup do
          @title = random_phrase
          @summary = random_phrase
          @text = "Title: #{@title}\nSummary: #{@summary}\n#{@text}"
        end
        should "create a work with the title and summary" do
          @work = @storyparser.parse_story(@text)
          assert @work.title == @title
          assert @work.summary == @summary
          assert @work.chapters.first.content == @text
        end
      end
    end

    context "given an HTML story" do
      setup do
        @content = random_chapter
        @title = random_phrase
        @text = "<html><head><title>#{@title}</title></head><body>#{@content}</body></html>"
      end
      should "create a work using the title tag and body content" do
        @work = @storyparser.parse_story(@text)
        assert @work.chapters.first.content == @content
        assert @work.title == @title
      end
    end

  end

  def test_set_work_attributes
    storyparser = StoryParser.new
    url = 'http://se-parsons.livejournal.com/895277.html'
    work = storyparser.download_and_parse_story(url)
    assert_equal url, work.imported_from_url
    assert_equal 1, work.expected_number_of_chapters    
  end

  def test_chapter_creation
    storyparser = StoryParser.new
    url = "http://www.yuletidetreasure.org/archive/40/birthpains.html"
    chapter = storyparser.download_and_parse_chapter(url)
    assert !chapter.content.blank?
    assert !chapter.title.blank?
    assert_equal "Birth Pains", chapter.title
    assert !chapter.summary.blank?
  end

  def test_livejournal_1
    storyparser = StoryParser.new
    url = 'http://se-parsons.livejournal.com/895277.html'
    work = storyparser.download_and_parse_story(url)
    assert_match /Dean started sweating/, work.chapters.first.content
    assert_match /de la mer/, work.title
  end

  # adult content
  def test_livejournal_adult
    storyparser = StoryParser.new
    url = 'http://x-strangeangels.livejournal.com/42435.html'
    work = storyparser.download_and_parse_story(url)
    assert_match /Dean finds her kneeling/, work.chapters.first.content
    assert_match /I dream of a circle/, work.title
  end

  # Test parsing of stories from yuletidetreasure.org
  def test_yuletide_1
    @storyparser = StoryParser.new

    url = "http://www.yuletidetreasure.org/archive/40/birthpains.html"
    @work = @storyparser.download_and_parse_story(url)
    assert !@work.chapters.first.content.blank?
    assert_equal "Birth Pains", @work.title
    assert !@work.summary.blank?
    @work.category_string = ArchiveConfig.CATEGORY_OTHER_TAG_NAME
    @work.warning_strings = [ArchiveConfig.WARNING_NONE_TAG_NAME]
    @work.authors = [create_pseud]
    @work.save
    assert_match /yuletide/, @work.freeforms.string
    assert_match "recipient:verity", @work.freeforms.string
    assert !@work.rating_string.blank?
    assert_match /The 10th Kingdom/, @work.fandoms.string
  end

  def test_yuletide_old
    @storyparser = StoryParser.new
    @url = "http://www.yuletidetreasure.org/archive/0/acertain.html"
    @work = @storyparser.download_and_parse_story(@url)
    assert !@work.chapters.first.content.blank?
    assert !@work.title.blank?
  end

  # single-chaptered work
  def test_ffnet
    @storyparser = StoryParser.new

    @url = "http://www.fanfiction.net/s/2180161/1/Hot_Springs"
    @work = @storyparser.download_and_parse_story(@url)
    assert_match /After many months/, @work.chapters.first.content
    assert_equal "Hot Springs", @work.title
    @work.category_string = ArchiveConfig.CATEGORY_OTHER_TAG_NAME
    @work.warning_strings = [ArchiveConfig.WARNING_NONE_TAG_NAME]
    @work.authors = [create_pseud]
    @work.save
    assert_equal "Naruto", @work.fandom_string
    assert_equal Rating.find_by_name(ArchiveConfig.RATING_TEEN_TAG_NAME), @work.ratings.first
  end

  #multi-chaptered work
  def test_ffnet_chapters
    @storyparser = StoryParser.new
    @url = "http://www.fanfiction.net/s/4545794/1/The_Memory_Remains"
    @work = @storyparser.download_and_parse_story(@url)
    assert !@work.title.blank?
    assert_equal "The Memory Remains", @work.title    
    assert !@work.chapters.first.content.blank?
    
    # put rest of chapters here
    assert @work.chapters.length == 6

    assert_equal "Awaken and Act", @work.chapters[0].title
    assert_equal 1, @work.chapters[0].position
    assert_match /Naruto was cooped up in some odd prison with nine cells/, @work.chapters[0].content

    assert_equal "Memories and the Mourning", @work.chapters[1].title
    assert_equal 2, @work.chapters[1].position
    assert_match /Kakashi scolded them once more/, @work.chapters[1].content

    assert_equal "Hapiness and the Hyuga", @work.chapters[2].title
    assert_equal 3, @work.chapters[2].position
    assert_match /Tsunade told Naruto he could leave the hospital/, @work.chapters[2].content

    assert_equal "Kool Aid", @work.chapters[3].title
    assert_equal 4, @work.chapters[3].position
    assert_match /Naruto screamed as the light crept into his room and woke him up/, @work.chapters[3].content

    assert_equal "Sasuke", @work.chapters[4].title
    assert_equal 5, @work.chapters[4].position
    assert_match /Sakura had put the kool aid dye in Naruto/, @work.chapters[4].content

    assert_equal "Given Up", @work.chapters[5].title
    assert_equal 6, @work.chapters[5].position
    assert_match /Sasuke jumped high into the air almost trying to land on Naruto/, @work.chapters[5].content
    
    assert_equal 6, @work.expected_number_of_chapters    
  end

  # "successfully parse a url with a storyinfo block in html comments with fandom"
  def test_storyinfo
    storyparser = StoryParser.new
    url = "http://www.intimations.org/fanfic/davidcook/Madrigals%20and%20Misadventures.html"
    work = storyparser.download_and_parse_story(url)
    assert_match /It was really cool/, work.chapters.first.content
    assert_match /Madrigals/, work.title
    assert_match /Wherein there is magic/, work.summary
    work.category_string = Category.first.name
    work.warning_strings = [Warning.first.name]
    work.authors = [create_pseud]
    work.save
    assert_match /Idol RPF/, work.fandoms.string
  end

  def test_remix
    @storyparser = StoryParser.new
    url = "http://remix.illuminatedtext.com/dbfiction.php?fiction_id=441"
    @work = @storyparser.download_and_parse_story(url)
    assert !@work.chapters.first.content.blank?
    assert @work.chapters.first.content.length > 500
    assert !@work.title.blank?
  end

  def test_archive_org
    @storyparser = StoryParser.new
    url = "http://web.archive.org/web/20040310174832/http://witchqueen.diary-x.com/journal.cgi?entry=20040108b"
    @work = @storyparser.download_and_parse_story(url)
    assert !@work.chapters.first.content.blank?
    assert @work.chapters.first.content.length > 500
    assert !@work.title.blank?
  end

  def test_rivkat
    @storyparser = StoryParser.new
    url = "http://rivkat.com/spn/three.html"
    @work = @storyparser.download_and_parse_story(url)
    assert !@work.chapters.first.content.blank?
    assert @work.chapters.first.content.length > 500
    assert !@work.title.blank?
  end

  def test_date
    @storyparser = StoryParser.new
    @url = "http://www.intimations.org/fanfic/master_and_commander/five_things-listening.html"
    @work = @storyparser.download_and_parse_story(@url)
    assert @work.chapters.first.published_at == Date.parse('2003-12-11')
  end

end
