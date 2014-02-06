require 'spec_helper'

describe StoryParser do
  
  before(:each) do
    @sp = StoryParser.new
  end

  describe "get_source_if_known:" do

    describe "the SOURCE_FFNET pattern" do

      it "should match http://fanfiction.net" do
        url = "http://fanfiction.net"
        @sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url).should eq("ffnet")
      end

      it "should match fanfiction.net" do
        url = "fanfiction.net"
        @sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url).should eq("ffnet")
      end

      it "should match http://www.fanfiction.net" do
        url = "http://www.fanfiction.net"
        @sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url).should eq("ffnet")
      end

      it "should match www.fanfiction.net" do
        url = "www.fanfiction.net"
        @sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url).should  eq("ffnet")
      end

      it "should not match http://adultfanfiction.net" do
        url = "http://adultfanfiction.net"
        @sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url).should be_nil
      end

      it "should not match adultfanfiction.net" do
        url = "adultfanfiction.net"
        @sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url).should be_nil
      end

      it "should not match http://www.adultfanfiction.net" do
        url = "http://www.adultfanfiction.net"
        @sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url).should be_nil
      end

      it "should not match www.adultfanfiction.net" do
        url = "www.adultfanfiction.net"
        @sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url).should be_nil
      end
    end

    describe "the SOURCE_LJ pattern" do
      # SOURCE_LJ = '((live|dead|insane)?journal(fen)?\.com)|dreamwidth\.org'
      it "should match a regular domain on livejournal" do
        url = "http://mydomain.livejournal.com"
        @sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url).should eq("lj")
      end

      it "should match a domain with underscores within on livejournal" do
        url = "http://my_domain.livejournal.com"
        @sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url).should eq("lj")
      end

      it "should match a folder style link to an individual user on livejournal" do
        url = "http://www.livejournal.com/users/_underscore"
        @sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url).should eq("lj")
      end

      it "should match a folder style link to a community on livejournal" do
        url = "http://www.livejournal.com/community/underscore_"
        @sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url).should eq("lj")
      end

      it "should match a domain on dreamwidth" do
        url = "http://mydomain.dreamwidth.org"
        @sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url).should eq("lj")
      end

      it "should match a domain on deadjournal" do
        url = "http://mydomain.deadjournal.com"
        @sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url).should eq("lj")
      end

      it "should match a domain on insanejournal" do
        url = "http://mydomain.insanejournal.com"
        @sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url).should eq("lj")
      end

      # TODO: uncomment and remove this comment when (if) fixing the bug
      it "should match a folder style link to an individual user on journalfen" # do
      #   url = "http://www.journalfen.net/users/username"
      #   @sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url).should eq("lj")
      # end
    end
    
    # TODO: KNOWN_STORY_PARSERS
  end
  
  describe "#parse_common" do
    it "should convert relative to absolute links" do
      # This one doesn't work because the sanitizer is converting the & to &amp;
      # ['http://foo.com/bar.html', 'search.php?here=is&a=query'] => 'http://foo.com/search.php?here=is&a=query',
      {      
       ['http://foo.com/bar.html', 'thisdir.html'] => 'http://foo.com/thisdir.html',
       ['http://foo.com/bar.html?hello=foo', 'thisdir.html'] => 'http://foo.com/thisdir.html',
       ['http://foo.com/bar.html', './thisdir.html'] => 'http://foo.com/thisdir.html',
       ['http://foo.com/bar.html', 'img.jpg'] => 'http://foo.com/img.jpg',
       ['http://foo.com/bat/bar.html', '../updir.html'] => 'http://foo.com/updir.html',
       ['http://foo.com/bar.html', 'http://bar.com/foo.html'] => 'http://bar.com/foo.html',
       ['http://foo.com/bar.html', 'search.php?hereis=aquery'] => 'http://foo.com/search.php?hereis=aquery',
      }.each_pair do |input, output|
        location, href = input
        story_in = '<html><body><p>here is <a href="' + href + '">a link</a>.</p></body></html>'
        story_out = 'here is <a href="' + output + '">a link</a>.'
        results = @sp.parse_common(story_in, location)
        expect(results[:chapter_attributes][:content]).to include(story_out)
      end
    end
  end
    
end
