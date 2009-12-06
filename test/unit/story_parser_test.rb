require File.dirname(__FILE__) + '/../test_helper'

class StoryParserTest < ActiveSupport::TestCase
  
  def setup
    @working_stories = [      
      {  :url => "http://suberic.net/~jadelennox/spikesees.html",
        :title => "The One Who Sees",
        :content => "He will not see my pain."}, 

      {  :url => "http://home.teleport.com/~punkm/lipstick.html",
        :title => "The Lipstick Mafia",
        :content => "And that's how the lipstick mafia got me and Fraser in the shower."}, 
      
      {  :url => "http://rivkat.com/smallville/angel.html",
        :title => "No Angel Came",
        :content => "He knows that Clark will not be there when he wakes."}, 
      
      {  :url => "http://cupidsbow.livejournal.com/147183.html",
        :title => "fractures",
        :content => "Zack whispers, his breath warm against her ear",
        :fandom => "Battlestar Galactica 2003",
        :rating => ArchiveConfig.RATING_TEEN_TAG_NAME}, 
      
      {  :url => "http://www.fanfiction.net/s/277511/1/Mindless_Fun",
        :title => "Mindless Fun",
        :content => "Neither of them said a word about the huge brown hand on John's thigh.",
        :fandom => "Farscape",
        :rating => ArchiveConfig.RATING_GENERAL_TAG_NAME}, 
      
      {  :url => "http://www.innergeekdom.net/Twice/12-01.htm",
        :title => "Inanimate Fruit",
        :content => "She shrugged, and kissed Meredith, softly with her lips closed and her hands at Meredith's waist.",
        :fandom => "Grey's Anatomy",
        :rating => ArchiveConfig.RATING_MATURE_TAG_NAME}, 

      {  :url => "http://apreludetoanend.livejournal.com/100193.html",
        :title => "Triptych",
        :content => "\"I want to go to college,\" he says."}, 

      {  :url => "http://x-strangeangels.livejournal.com/42435.html",
        :title => "I dream of a circle",
        :content => "Mundi tenebricosi.",
        :rating => ArchiveConfig.RATING_MATURE_TAG_NAME}, 

      {  :url => "http://se-parsons.livejournal.com/895277.html",
        :title => "L'etoile de la mer",
        :content => "When Dean slept, he dreamt of the ocean.",
        :rating => ArchiveConfig.RATING_TEEN_TAG_NAME}, 
      ]
      
    @nonworking_stories = [
      {:url => "http://asdklfjsdf.com"}
      ]
            
    @quote_stories = [
      {  :url => "http://rivkat.com/spn/three.html",
        :title => "Three Answers",
        :content => "\"I call first shower,\" Sam said, and then they were off and running towards"}, 
      
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
        assert_match @text, @work.chapters.first.content
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
          assert_match @text, @work.chapters.first.content
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
        assert @work.chapters.first.content == @content
        assert @work.title == @title
      end
    end
  end

  def test_set_work_attributes
    storyparser = StoryParser.new
    url = 'http://se-parsons.livejournal.com/895277.html'
    work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_equal url, work.imported_from_url
    assert_equal 1, work.expected_number_of_chapters    
  end

  def test_chapter_of_work
    storyparser = StoryParser.new
    work = create_work
    num_chapters = work.chapters.length 
    url = "http://apreludetoanend.livejournal.com/100193.html"
    work = storyparser.download_and_parse_chapter_of_work(work, url, :pseuds => [create_pseud])
    assert_equal work.chapters.length, num_chapters + 1
    chapter = work.chapters.last 
    assert !chapter.content.blank?
    assert_match /\"I want to go to college,\" he says./, chapter.content
    assert !chapter.title.blank?
    assert_match /Triptych/, chapter.title
  end

  def test_livejournal_1
    storyparser = StoryParser.new
    url = 'http://se-parsons.livejournal.com/895277.html'
    work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_match /Dean started sweating/, work.chapters.first.content
    assert_match /de la mer/, work.title
  end

  # adult content
  def test_livejournal_adult
    storyparser = StoryParser.new
    url = 'http://x-strangeangels.livejournal.com/42435.html'
    work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_match /Dean finds her kneeling/, work.chapters.first.content
    assert_match /I dream of a circle/, work.title
  end
  
  def test_livejournal_cutid
    storyparser = StoryParser.new
    url = 'http://angstslashhope.livejournal.com/1560574.html#cutid1'
    work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_match /Jack had liked the old one far better/, work.chapters.first.content
    assert_match /Kiss Kiss, Pew Pew/, work.title
    assert_no_match /Adventures in space for great yay/, work.chapters.first.content
  end

  # test importing of stories with long fandom
  def test_long_fandom
    @storyparser = StoryParser.new

    url = "http://yuletidetreasure.org/archive/33/duende.html"
    work = @storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_match /Patrick OBrian/, work.fandoms.first.name
    assert work.fandoms.first.name.length <= ArchiveConfig.TAG_MAX    
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
  
  def test_ffnet_general
    @storyparser = StoryParser.new
    @url = "http://www.fanfiction.net/s/4881862/1/Fleeting_Dreams"
    @work = @storyparser.download_and_parse_story(@url, :pseuds => [create_pseud])
    assert @work.save
  end

  #multi-chaptered work
  def test_ffnet_chapters
    @storyparser = StoryParser.new
    @url = "http://www.fanfiction.net/s/4545794/1/The_Memory_Remains"
    @work = @storyparser.download_and_parse_story(@url, :pseuds => [create_pseud])
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
    work = storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert_match /It was really cool/, work.chapters.first.content
    assert_match /Madrigals/, work.title
    assert_match /Wherein there is magic/, work.summary
    work.category_string = Category.first.name
    work.warning_strings = [Warning.first.name]
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
    @work = @storyparser.download_and_parse_story(url, :pseuds => [create_pseud])
    assert !@work.chapters.first.content.blank?
    assert @work.chapters.first.content.length > 500
    assert !@work.title.blank?
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
      "http://www.rivkat.com/index.php?set=fiction&story=85&chapter=3",
      "http://www.rivkat.com/index.php?set=fiction&story=85&chapter=4",
      ]
      
    work = storyparser.download_and_parse_chapters_into_story(urls, :pseuds => [create_pseud])

    assert_equal 4, work.expected_number_of_chapters
    assert_equal 4, work.chapters.length
    assert_match "obviously realizing only now that he had to be Lex Luthor for an undetermined", work.chapters[0].content
    assert_match "making no concessions to his unfamiliar fingers", work.chapters[1].content
    assert_match "Pleading temporary insanity had worked before", work.chapters[2].content
    assert_match "bottom half of the shirt was held together by force of Lexian will", work.chapters[3].content
  end
  
  def test_parse_author
    storyparser = StoryParser.new
    url = "http://astolat.livejournal.com/213456.html"
    
    assert external_author_name = storyparser.parse_author(url)
    assert external_author = external_author_name.external_author
    assert_equal "shalott@intimations.org", external_author.email
    assert external_author.names.first
    assert_equal "astolat", external_author.names.first.name
  end
  
  def test_importing_for_others
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
      begin
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
      rescue Timeout::Error
        puts "Timed out trying to get #{entry[:url]}"
      end
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
    
    # test import_from_urls
    @results = storyparser.import_from_urls( (@working_stories + @nonworking_stories).collect {|entry| entry[:url]}, :pseuds => [create_pseud])
    @result_works = @results[0]
    @result_failed_urls = @results[1]
    assert_equal 9, @result_works.length
    assert_equal 1, @result_failed_urls.length
    for i in 0..(@working_stories.length-1) do
      work = @result_works[i]
      entry = @working_stories[i]
      assert_match entry[:content], work.chapters.first.content
      assert_match entry[:title], work.title
      assert_match entry[:fandom], work.fandom_string if entry[:fandom]
      assert_equal Rating.find_by_name(entry[:rating]), work.ratings.first if entry[:rating]

      # make sure work is valid and can be saved
      assert work.save
    end
  end
  
  def test_quotes
    puts "DEFERRED quotes testing until after yuletide"
    # @results = storyparser.import_from_urls( @quote_stories.collect {|entry| entry[:url]}, :pseuds => [create_pseud])
    # @result_works = @results[0]
    # for i in 0..11 do
    #   work = @result_works[i]
    #   entry = @working_stories[i]
    #   assert_match entry[:content], work.chapters.first.content
    # end
  end

  def test_import_yuletide_with_authors
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
  end
  

end
