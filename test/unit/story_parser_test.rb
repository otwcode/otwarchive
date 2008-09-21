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
    
    context "given a set of Livejournal urls" do
      setup do
        @urls = []
        @urls << 'http://black-samvara.livejournal.com/381224.html'
        @urls << 'http://black-samvara.livejournal.com/379835.html'
        @urls << 'http://se-parsons.livejournal.com/895277.html'
        @urls << 'http://x-strangeangels.livejournal.com/42435.html'
        @urls << 'http://apreludetoanend.livejournal.com/100193.html'
      end
      should "successfully create a work with title for all of them" do
        @urls.each do |url|
          @work = @storyparser.download_and_parse_story(url)
          assert !@work.chapters.first.content.blank?
          assert !@work.title.blank?
        end
      end
    end
    
    context "given a set of Yuletide urls" do
      setup do
        @urls = []
        @urls << "http://www.yuletidetreasure.org/archive/40/birthpains.html"
        @urls << "http://www.yuletidetreasure.org/archive/31/theend.html"
        @urls << "http://www.yuletidetreasure.org/archive/20/ourscars.html"
        @urls << "http://www.yuletidetreasure.org/archive/14/fleeor.html"
      end
      should "successfully create a work with title and fandom for all of them" do
        @urls.each do |url|
          @work = @storyparser.download_and_parse_story(url)
          assert !@work.chapters.first.content.blank?
          assert !@work.title.blank?
          assert !@work.summary.blank? 
          assert !@work.tags_to_tag_with.blank?
          assert @work.tags_to_tag_with[:default].match(/yuletide/)
          assert @work.tags_to_tag_with[:default].match(/rating/)
          assert @work.tags_to_tag_with[:default].match(/recipient/)
          assert @work.tags_to_tag_with[:default].match(/fandom/)
        end
      end
    end    

    context "given an old Yuletide url" do
      setup do
        @url = "http://www.yuletidetreasure.org/archive/0/acertain.html"
      end
      should "successfully get the content and title" do
        @work = @storyparser.download_and_parse_story(@url)
        assert !@work.chapters.first.content.blank?
        assert !@work.title.blank?
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
    
    context "given an ffnet url for a multi-chaptered work" do
      setup do
        @url = "http://www.fanfiction.net/s/4545794/1/The_Memory_Remains"
      end
      should_eventually "successfully create it as a multichaptered story" do
        @work = @storyparser.download_and_parse_story(@url)
        assert !@work.chapters.first.content.blank?
        assert !@work.title.blank?        
      end
    end

    context "given other tricky urls" do
      setup do
        @urls = []
        @urls << "http://www.innergeekdom.net/Twice/12-01"
        @urls << "http://remix.illuminatedtext.com/dbfiction.php?fiction_id=441"
        @urls << "http://web.archive.org/web/20040310174832/http://witchqueen.diary-x.com/journal.cgi?entry=20040108b"
      end
      should_eventually "successfully create a work" do
        @urls.each do |url|
          @work = @storyparser.download_and_parse(url)
          assert !@work.chapters.first.content.blank?
          assert !@work.title.blank?
        end
      end
    end
    
  end
end
