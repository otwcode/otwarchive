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
    
    context "given a url for a chapter" do
      setup do
        @url = "http://www.yuletidetreasure.org/archive/40/birthpains.html"
      end
      should_eventually "create a chapter" do
        @chapter = @storyparser.download_and_parse_chapter(@url)
        assert !@chapter.content.blank?
        assert !@chapter.title.blank?
        assert !@chapter.summary.blank?
      end
    end 

  end
  
  def test_livejournal
    @storyparser = StoryParser.new      
    @urls = []
    @urls << 'http://black-samvara.livejournal.com/381224.html'
    @urls << 'http://black-samvara.livejournal.com/379835.html'
    @urls << 'http://se-parsons.livejournal.com/895277.html'
    @urls << 'http://x-strangeangels.livejournal.com/42435.html'
    @urls << 'http://apreludetoanend.livejournal.com/100193.html'
    @urls.each do |url|
      @work = @storyparser.download_and_parse_story(url)
      assert !@work.chapters.first.content.blank?
      assert !@work.title.blank?
    end
  end
  
  # Test parsing of stories from yuletidetreasure.org
  def test_yuletide
    @storyparser = StoryParser.new      

    @urls = []
    @urls << "http://www.yuletidetreasure.org/archive/40/birthpains.html"
    @urls << "http://www.yuletidetreasure.org/archive/31/theend.html"
    @urls << "http://www.yuletidetreasure.org/archive/20/ourscars.html"
    @urls << "http://www.yuletidetreasure.org/archive/14/fleeor.html"

    @urls.each do |url|
      @work = @storyparser.download_and_parse_story(url)
      assert !@work.chapters.first.content.blank?
      assert !@work.title.blank?
      assert !@work.summary.blank? 
      assert !@work.tags_to_tag_with.blank?
      assert @work.tags_to_tag_with[:default].match(/yuletide/)
      assert @work.tags_to_tag_with[:default].match(/recipient/)
      assert !@work.tags_to_tag_with[:rating].blank?
      assert !@work.tags_to_tag_with[:fandom].blank?
    end

    # ancient url that doesn't work?
    puts "Deferred: parsing very old yuletide stories"
    # @url = "http://www.yuletidetreasure.org/archive/0/acertain.html"
    # @work = @storyparser.download_and_parse_story(@url)
    # assert !@work.chapters.first.content.blank?
    # assert !@work.title.blank?
  end

  def test_ffnet
    @storyparser = StoryParser.new      
    
    # single-chaptered work
    @url = "http://www.fanfiction.net/s/2180161/1/Hot_Springs"     
    @work = @storyparser.download_and_parse_story(@url)
    assert !@work.chapters.first.content.blank?
    assert !@work.title.blank?
    assert @work.title.match(/Hot Springs/)
    assert @work.tags_to_tag_with[:fandom].match(/Naruto/)
    assert @work.tags_to_tag_with[:rating] == ArchiveConfig.TEEN_RATING_TAG_NAME           

    #multi-chaptered work -- not yet working
    puts "Deferred: parsing multi-chaptered ffnet stories"
    # @url = "http://www.fanfiction.net/s/4545794/1/The_Memory_Remains"
    # @work = @storyparser.download_and_parse_story(@url)
    # assert !@work.chapters.first.content.blank?
    # assert !@work.title.blank?        
  end
  
  def test_storyinfo
    @storyparser = StoryParser.new      
    # "successfully parse a url with a storyinfo block in html comments with fandom" 
    @url = "http://www.intimations.org/fanfic/davidcook/Madrigals%20and%20Misadventures.html"
    @work = @storyparser.download_and_parse_story(@url)
    assert !@work.chapters.first.content.blank?
    assert !@work.title.blank?
    assert !@work.summary.blank?
    assert @work.tags_to_tag_with[:fandom].match(/David Cook RPF/)
  end

  def test_previous_failures
    @storyparser = StoryParser.new      
    @urls = []
    @urls << "http://remix.illuminatedtext.com/dbfiction.php?fiction_id=441"
    @urls << "http://web.archive.org/web/20040310174832/http://witchqueen.diary-x.com/journal.cgi?entry=20040108b"
    @urls.each do |url|
      @work = @storyparser.download_and_parse_story(url)
      assert !@work.chapters.first.content.blank?
      assert !@work.title.blank?
    end
  end

end
