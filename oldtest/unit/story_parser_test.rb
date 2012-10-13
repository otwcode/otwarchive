require 'test_helper'

class StoryParserTest < ActiveSupport::TestCase
  
  include HtmlCleaner
  
  def setup
    @working_stories = [      
      # note, files use url modifications and go past adult notices
      # those are tested in other tests which are not mocked

      # first working_stories entry must have title, fandom and rating for test_import_from_urls
      {  :url => "http://cupidsbow.livejournal.com/147183.html",
        :file => "147183.html",  
        :title => "fractures",
        :content => "Zack whispers, his breath warm against her ear",
        :fandom => "Battlestar Galactica 2003",
        :rating => ArchiveConfig.RATING_TEEN_TAG_NAME}, 
      
      {  :url => "http://suberic.net/~jadelennox/spikesees.html",
        :file => "spikesees.html",
        :title => "The One Who Sees",
        :content => "He will not see my pain."}, 

      {  :url => "http://home.teleport.com/~punkm/lipstick.html",
        :file => "lipstick.html",
        :title => "The Lipstick Mafia",
        :content => "And that's how the lipstick mafia got me and Fraser in the shower."}, 
      
      {  :url => "http://rivkat.com/smallville/angel.html",
        :file => "angel.html",
        :title => "No Angel Came",
        :content => "He knows that Clark will not be there when he wakes."}, 
      
      {  :url => "http://www.fanfiction.net/s/277511/1/Mindless_Fun",
        :file => "Mindless_Fun.html",
        :title => "Mindless Fun",
        :content => "Neither of them said a word about the huge brown hand on John's thigh.",
        :fandom => "Farscape",
        :rating => ArchiveConfig.RATING_GENERAL_TAG_NAME}, 
      
      {  :url => "http://www.innergeekdom.net/Twice/12-01.htm",
        :file => "12-01.htm",
        :title => "Inanimate Fruit",
        :content => "She shrugged, and kissed Meredith, softly with her lips closed and her hands at Meredith's waist.",
        :fandom => "Grey's Anatomy",
        :rating => ArchiveConfig.RATING_MATURE_TAG_NAME}, 

      {  :url => "http://apreludetoanend.livejournal.com/100193.html",
        :file => "100193.html",
        :title => "Triptych",
        :content => "\"I want to go to college,\" he says."}, 

      {  :url => "http://x-strangeangels.livejournal.com/42435.html",
        :file => "42435.html",
        :title => "I dream of a circle",
        :content => "Mundi tenebricosi.",
        :rating => ArchiveConfig.RATING_MATURE_TAG_NAME}, 

      {  :url => "http://se-parsons.livejournal.com/895277.html",
        :file => "895277.html",
        :title => "L'etoile de la mer",
        :content => "When Dean slept, he dreamt of the ocean.",
        :rating => ArchiveConfig.RATING_TEEN_TAG_NAME}, 
        
      ] 
  end

  context "a storyparser" do
    setup do
      @storyparser = StoryParser.new
    end

    context "given a plaintext story" do
      setup do
        @text = random_chapter
        @location = nil
      end
      should "create a new unposted work with the text as its content" do
        @work = @storyparser.parse_story(@text, @location, :pseuds => [create_pseud])
        assert !@work.posted
        assert_match clean_fully(@text), @work.chapters.first.content
        assert @work.valid?
      end
      context "with the title and summary in the text" do
        setup do
          @title = random_phrase
          @summary = random_phrase
          @text = "Title: #{@title}\nSummary: #{@summary}\n#{@text}"
        end
        should "create a work with the title and summary" do
          @work = @storyparser.parse_story(@text, @location, :pseuds => [create_pseud])
          assert @work.title == @title
          assert @work.summary == @summary
          assert_match clean_fully(@text), @work.chapters.first.content
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
        @work = @storyparser.parse_story(@text, @location, :pseuds => [create_pseud])
        assert @work.chapters.first.content == clean_fully(@content)
        assert @work.title == @title
      end
    end
  end

  def test_set_work_attributes
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", 
                     :body => File.read(Rails.root + "test/mocks/stories/895277.html"))
    storyparser = StoryParser.new
    url = 'http://se-parsons.livejournal.com/895277.html'
    work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_equal url, work.imported_from_url
    assert_equal 1, work.expected_number_of_chapters
  end

  def test_chapter_of_work
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", 
                     :body => File.read(Rails.root + "test/mocks/stories/100193.html"))
    storyparser = StoryParser.new
    work = create_work
    num_chapters = work.chapters.length 
    url = "http://apreludetoanend.livejournal.com/100193.html"
    work = storyparser.download_and_parse_chapter_of_work(work, url, :pseuds => [create_pseud])
    assert_equal work.chapters.length, num_chapters + 1
    chapter = work.chapters.last 
    assert !chapter.content.blank?
    assert_match /\"I want to go to college,\" he says./, chapter.content  #"
    assert !chapter.title.blank?
    assert_match /Triptych/, chapter.title
  end

#   FIXME encoding wrong
#   def test_encoding
#     storyparser = StoryParser.new
#     url = "http://rivkat.com/spn/three.html"
#     work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
#     assert_match /Three Answers/, work.title
#     assert_match "\"I call first shower,\" Sam said", work.chapters.first.content
#   end
#     

  # adult content
  def test_livejournal_adult
    storyparser = StoryParser.new
    url = 'http://x-strangeangels.livejournal.com/42435.html'
    work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_match /Dean finds her kneeling/, work.chapters.first.content
    assert_match /I dream of a circle/, work.title
  end
  
# story has been moved
#  def test_livejournal_cutid
#    storyparser = StoryParser.new
#    url = 'http://angstslashhope.livejournal.com/1560574.html#cutid1'
#    work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
#    assert_match /Jack had liked the old one far better/, work.chapters.first.content
#    assert_match /Kiss Kiss, Pew Pew/, work.title
#    assert_no_match /Adventures in space for great yay/, work.chapters.first.content
#  end

  # test importing of stories with long fandom
  def test_long_fandom
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", 
                     :body => File.read(Rails.root + "test/mocks/stories/duende.html"))
    @storyparser = StoryParser.new
    url = "http://yuletidetreasure.org/archive/33/duende.html"
    work = @storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_match /Patrick OBrian/, work.fandoms.first.name
    assert work.fandoms.first.name.length <= ArchiveConfig.TAG_MAX    
  end

  def test_yuletide
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", 
                     :body => File.read(Rails.root + "test/mocks/stories/littlemiss.html"))
    @storyparser = StoryParser.new
    url = "http://yuletidetreasure.org/archive/79/littlemiss.html"
    work = @storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_match /A horrified silence fell over the classroom./, work.chapters.first.content
    assert_equal "Little Miss Curious", work.title
    assert work.save
    assert_match /Little Miss Sunshine/, work.fandoms.first.name
    assert_match /Yule Madness Treat, unbetaed./, work.notes
    assert_no_match /Search Engine/, work.chapters.first.content
  end
  
  # single-chaptered work
  def test_ffnet
    @storyparser = StoryParser.new
    @url = "http://www.fanfiction.net/s/2180161/1/Hot_Springs"
    @work = @storyparser.download_and_parse_story(@url, :pseuds => [create_pseud])
    assert_match /After many months/, @work.chapters.first.content
    assert_equal "Hot Springs", @work.title
    assert @work.save
    assert_equal "Naruto", @work.fandom_string
    assert_equal Rating.find_by_name(ArchiveConfig.RATING_TEEN_TAG_NAME), @work.ratings.first
  end
  
  #multi-chaptered work
  def test_ffnet_chapters
    @storyparser = StoryParser.new
    @url = "http://www.fanfiction.net/s/5853866/1/Counting"
    @work = @storyparser.download_and_parse_story(@url, :pseuds => [create_pseud])
    assert !@work.title.blank?
    assert_equal "Counting", @work.title    
    assert !@work.chapters.first.content.blank?
    assert @work.chapters.length == 2

    assert_equal "Skipping Stones", @work.chapters[0].title
    assert_equal 1, @work.chapters[0].position
    assert_match /He stood gazing out over the lake for a long time/, @work.chapters[0].content

    assert_equal "The Flower", @work.chapters[1].title
    assert_equal 2, @work.chapters[1].position
    assert_match /Into his future/, @work.chapters[1].content

    assert_equal 2, @work.expected_number_of_chapters    
  end

  # "successfully parse a url with a storyinfo block in html comments with fandom"
  def test_storyinfo
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", 
                     :body => File.read(Rails.root + "test/mocks/stories/misadventures.html"))
    storyparser = StoryParser.new
    url = "http://www.intimations.org/fanfic/davidcook/Madrigals%20and%20Misadventures.html"
    work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_match /It was really cool/, work.chapters.first.content
    assert_match /Madrigals/, work.title
    assert_match /Wherein there is magic/, work.summary
    work.category_string = random_tag_name
    work.warning_strings = [random_tag_name]
    work.authors = [create_pseud]
    work.save
    assert_match /Idol RPF/, work.fandoms.string
  end

  # def test_remix
  #   @storyparser = StoryParser.new
  #   url = "http://remix.illuminatedtext.com/dbfiction.php?fiction_id=441"
  #   @work = @storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
  #   assert !@work.chapters.first.content.blank?
  #   assert @work.chapters.first.content.length > 500
  #   assert !@work.title.blank?
  # end

  def test_archive_org
    @storyparser = StoryParser.new
    url = "http://web.archive.org/web/20040310174832/http://witchqueen.diary-x.com/journal.cgi?entry=20040108b"
    begin
      @work = @storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
      assert !@work.chapters.first.content.blank?
      assert @work.chapters.first.content.length > 500
      assert !@work.title.blank?
    rescue Timeout::Error
    end
  end

  def test_rivkat
    @storyparser = StoryParser.new
    url = "http://rivkat.com/spn/three.html"
    @work = @storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert !@work.chapters.first.content.blank?
    assert @work.chapters.first.content.length > 500
    assert !@work.title.blank?
  end

  def test_date
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", 
                     :body => File.read(Rails.root + "test/mocks/stories/five_things-listening.html"))
    @storyparser = StoryParser.new
    @url = "http://www.intimations.org/fanfic/master_and_commander/five_things-listening.html"
    @work = @storyparser.download_and_parse_story(@url, :pseuds => [create_pseud])
    assert @work.chapters.first.published_at == Date.parse('2003-12-11')
  end
  
  def test_manual_chapters
    storyparser = StoryParser.new
    urls = [
      "http://www.rivkat.com/index.php?set=fiction&story=85&chapter=1",
      "http://www.rivkat.com/index.php?set=fiction&story=85&chapter=2",
      ]
      
    work = storyparser.download_and_parse_chapters_into_story(urls, :pseuds => [create_pseud])

    assert_equal 2, work.expected_number_of_chapters
    assert_equal 2, work.chapters.length
    assert_match "obviously realizing only now that he had to be Lex Luthor for an undetermined", work.chapters[0].content
    assert_match "making no concessions to his unfamiliar fingers", work.chapters[1].content
  end
  
  def test_parse_author
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", 
                     :body => File.read(Rails.root + "test/mocks/stories/213456.html"))
    storyparser = StoryParser.new
    url = "http://astolat.livejournal.com/213456.html"
    
    assert external_author_name = storyparser.parse_author(url)
    assert external_author = external_author_name.external_author
    assert_equal "shalott@intimations.org", external_author.email
    assert external_author.names.first
    assert_equal "astolat", external_author.names.first.name
  end
  
  def test_importing_for_others
    http_mock = mock('Net::HTTPResponse')
    http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", 
                     :body => File.read(Rails.root + "test/mocks/stories/213456.html"))
    storyparser = StoryParser.new
    url = "http://astolat.livejournal.com/213456.html"
    archivist = create_user
    work = storyparser.download_and_parse_story(url, :importing_for_others => true, :archivist => archivist)    
    
    assert work.save
    assert_equal work.users.first, archivist
    assert work.external_author_names.first
    assert_equal work.external_author_names.first.name, "astolat"
  end
    
  def test_problematic_stories_individually
    storyparser = StoryParser.new
    pseud = create_pseud
    @working_stories.each do |entry|
      http_mock = mock('Net::HTTPResponse')
      http_mock.stubs(:code => '200', :message => "OK", :content_type => "text/html", 
                       :body => File.read(Rails.root + "test/mocks/stories/" + entry[:file]))
      assert work = storyparser.download_and_parse_story(entry[:url], :pseuds => [pseud])
      assert !work.chapters.first.content.blank?
      assert_match entry[:content], work.chapters.first.content
      assert_match entry[:title], work.title
      # put in default warning so we can save
      work.warning_strings = [ArchiveConfig.WARNING_NONE_TAG_NAME]
      work.authors = [create_pseud]
      assert work.save
      assert_match entry[:fandom], work.fandom_string if entry[:fandom]
      assert_equal Rating.find_by_name(entry[:rating]), work.ratings.first if entry[:rating]
    end
  end
  
  def test_bad_import
    storyparser = StoryParser.new
    url = "http://adkjalfsd.com/aldkfjasdf.html"
    @work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert !@work.valid?
    assert !@work.save
    assert @work.delete
  end
  
  def test_import_from_urls
    storyparser = StoryParser.new
    entry = @working_stories[0]
    @results = storyparser.import_from_urls( [entry[:url], "http://asdklfjsdf.com"], :pseuds => [create_pseud])
    @result_failed_urls = @results[1]
    assert_equal 1, @result_failed_urls.length
    @result_works = @results[0]
    assert_equal 1, @result_works.length
    work = @result_works[0]
    assert_match entry[:content], work.chapters.first.content
    assert_match entry[:title], work.title
    assert_match entry[:fandom], work.fandom_string
    assert_equal Rating.find_by_name(entry[:rating]), work.ratings.first
    # make sure work is valid and can be saved
    assert work.save
  end
  
  # def test_import_yuletide_with_authors
    # DEFERRED yuletide import test while search down"
    # storyparser = StoryParser.new
    # @results = storyparser.import_from_urls(@yuletide_stories.collect {|entry| entry[:url]}, :importing_for_others => true, :pseuds => [create_pseud])
    # @result_works = @results[0]
    # assert_equal 3, @result_works.length
    # for i in 0..2 do
    #   work = @result_works[i]
    #   entry = @yuletide_stories[i]
    #   assert_match entry[:content], work.chapters.first.content
    #   assert_match entry[:title], work.title
    #   assert_match entry[:fandom], work.fandom_string if entry[:fandom]
    #   assert_equal Rating.find_by_name(entry[:rating]), work.ratings.first if entry[:rating]
    # 
    #   assert !work.external_authors.empty?
    #   assert_equal work.external_authors.first.email, "shalott@intimations.org"
    # end
  # end
  

end
