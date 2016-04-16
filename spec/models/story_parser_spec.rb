require 'spec_helper'
require 'webmock'

describe StoryParser do

  # Temporarily make the methods we want to test public
  before(:all) do
    class StoryParser
      public :get_source_if_known, :check_for_previous_import, :parse_common
    end
  end
  
  after(:all) do
    class StoryParser
      protected :get_source_if_known, :check_for_previous_import, :parse_common
    end
  end

  before(:each) do
    @sp = StoryParser.new
  end

  # Let the test get at external sites, but stub out anything containing "foo1" and "foo2"
  WebMock.allow_net_connect!
  WebMock.stub_request(:any, /foo1/).
    to_return(status: 200, body: "Date: 2001-01-10 13:45\nstubbed response", headers: {})
  WebMock.stub_request(:any, /foo2/).
    to_return(status: 200, body: "Date: 2001-01-22 12:56\nstubbed response", headers: {})

  describe "get_source_if_known:" do

    describe "the SOURCE_FFNET pattern" do

      it "should match http://fanfiction.net" do
        url = "http://fanfiction.net"
        expect(@sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url)).to eq("ffnet")
      end

      it "should match fanfiction.net" do
        url = "fanfiction.net"
        expect(@sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url)).to eq("ffnet")
      end

      it "should match http://www.fanfiction.net" do
        url = "http://www.fanfiction.net"
        expect(@sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url)).to eq("ffnet")
      end

      it "should match www.fanfiction.net" do
        url = "www.fanfiction.net"
        expect(@sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url)).to  eq("ffnet")
      end

      it "should not match http://adultfanfiction.net" do
        url = "http://adultfanfiction.net"
        expect(@sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url)).to be_nil
      end

      it "should not match adultfanfiction.net" do
        url = "adultfanfiction.net"
        expect(@sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url)).to be_nil
      end

      it "should not match http://www.adultfanfiction.net" do
        url = "http://www.adultfanfiction.net"
        expect(@sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url)).to be_nil
      end

      it "should not match www.adultfanfiction.net" do
        url = "www.adultfanfiction.net"
        expect(@sp.get_source_if_known(StoryParser::CHAPTERED_STORY_LOCATIONS, url)).to be_nil
      end
    end

    describe "the SOURCE_LJ pattern" do
      # SOURCE_LJ = '((live|dead|insane)?journal(fen)?\.com)|dreamwidth\.org'
      it "should match a regular domain on livejournal" do
        url = "http://mydomain.livejournal.com"
        expect(@sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url)).to eq("lj")
      end

      it "should match a domain with underscores within on livejournal" do
        url = "http://my_domain.livejournal.com"
        expect(@sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url)).to eq("lj")
      end

      it "should match a folder style link to an individual user on livejournal" do
        url = "http://www.livejournal.com/users/_underscore"
        expect(@sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url)).to eq("lj")
      end

      it "should match a folder style link to a community on livejournal" do
        url = "http://www.livejournal.com/community/underscore_"
        expect(@sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url)).to eq("lj")
      end

      it "should match a domain on dreamwidth" do
        url = "http://mydomain.dreamwidth.org"
        expect(@sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url)).to eq("lj")
      end

      it "should match a domain on deadjournal" do
        url = "http://mydomain.deadjournal.com"
        expect(@sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url)).to eq("lj")
      end

      it "should match a domain on insanejournal" do
        url = "http://mydomain.insanejournal.com"
        expect(@sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url)).to eq("lj")
      end

      it "should match a folder style link to an individual user on journalfen" do
        url = "http://www.journalfen.net/users/username"
        expect(@sp.get_source_if_known(StoryParser::KNOWN_STORY_LOCATIONS, url)).to eq("lj")
      end
    end

    # TODO: KNOWN_STORY_PARSERS
  end

  describe "check_for_previous_import" do
    let(:location_with_www) { "http://www.testme.org/welcome_to_test_vale.html" }
    let(:location_no_www) { "http://testme.org/welcome_to_test_vale.html" }
    let(:location_partial_match) { "http://testme.org/welcome_to_test_vale/12345" }

    it "should recognise previously imported www. works" do
      @work = FactoryGirl.create(:work, imported_from_url: location_with_www)

      expect { @sp.check_for_previous_import(location_no_www) }.to raise_exception(StoryParser::Error)
    end

    it "should recognise previously imported non-www. works" do
      @work = FactoryGirl.create(:work, imported_from_url: location_no_www)

      expect { @sp.check_for_previous_import(location_with_www) }.to raise_exception(StoryParser::Error)
    end

    it "should not perform a partial match on work import locations" do
      @work = create(:work, imported_from_url: location_partial_match)

      expect { @sp.check_for_previous_import("http://testme.org/welcome_to_test_vale/123") }.to_not raise_exception
    end
  end

  describe "#download_and_parse_chapters_into_story" do
    it "should set the work revision date to the date of the last chapter" do
      user = create(:user)
      urls = %w(http://foo1 http://foo2)
      work = @sp.download_and_parse_chapters_into_story(urls, { pseuds: [user.default_pseud], do_not_set_current_author: false })
      work.save
      actual_date = work.revised_at.in_time_zone.strftime('%FT%T%:z')
      expected_date = DateTime.new(2001, 1, 22).in_time_zone.strftime('%FT%T%:z')
      expect(actual_date).to eq(expected_date)
    end
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
        story_out = '<p>here is <a href="' + output + '">a link</a>.</p>'
        results = @sp.parse_common(story_in, location)
        expect(results[:chapter_attributes][:content]).to include(story_out)
      end
    end
  end
end
