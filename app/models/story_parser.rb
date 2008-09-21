# Parse stories from other websites and uploaded files, looking for metadata to harvest
# and put into the archive. 
# 
# This class depends heavily on the official tag categories of the archive. 
class StoryParser
  require 'hpricot'
  include HtmlFormatter
  
  META_PATTERNS = {:title => 'Title', :notes => 'Note', :summary => 'Summary', :default => "Tag"}

  # These lists will stop with the first one it matches, so put more-specific matches
  # towards the front of the list. 

  # places for which we have a custom parse_story_from_[source] method
  # for getting information out of the downloaded text
  KNOWN_STORY_PARSERS = %w(lj yuletide ffnet)

  # places for which we have a download_story_from_[source]
  # used to customize the downloading process
  KNOWN_STORY_LOCATIONS = %w(lj)

  # places for which we have a download_chaptered_from
  # to get a set of chapters all together
  CHAPTERED_STORY_LOCATIONS = %w(ffnet)
  
  # regular expressions to match against the URLS
  SOURCE_LJ = '(live|dead|insane)?journal(fen)?\.com'
  SOURCE_YULETIDE = 'yuletidetreasure\.org'
  SOURCE_FFNET = 'fanfiction\.net'

  # Downloads a story and passes it on to the parser. 
  # If the URL of the story is from a site for which we have special rules 
  # (eg, downloading from a livejournal clone, you want to use ?format=light
  # to get a nice and consistent post format), it will pre-process the url
  # according to the rules for that site. 
  def download_and_parse_story(location)
    source = get_source_if_known(CHAPTERED_STORY_LOCATIONS, location)
    if source.nil?
      story = download_text(location)    
      return parse_story(story, location)
    else
      return download_and_parse_chaptered_story(source, location)
    end
  end

  def download_and_parse_chapter(location)
    story = download_text(location)
    return parse_chapter(story, location)
  end

  # Parses the text of a story, optionally from a given location. 
  def parse_story(story, location = nil)
    work_params = parse_text(story, location)
    return Work.new(work_params)
  end

  # Parses text but returns a chapter instead
  def parse_chapter(chapter, location = nil)
    work_params = parse_text(chapter, location)
    @chapter = get_chapter_from_work_params(work_params)
    return @chapter
  end

  # Everything below here is protected and should not be touched by outside
  # code -- please use the above functions to parse stories. 

  protected
    def get_source_if_known(known_sources, location)
      known_sources.each do |source|
        pattern = Regexp.new(eval("SOURCE_#{source.upcase}"), Regexp::IGNORECASE)
        if location.match(pattern)
          return source
        end
      end
      nil
    end      
  
    def download_and_parse_chaptered_story(source, location)
      work_params = { :title => "UPLOADED WORK", :chapter_attributes => {} }
      chapter_contents = eval("download_chaptered_from_#{source.downcase}(location)")
      @work = nil
      chapter_contents.each do |content|        
        @doc = Hpricot(content)
        chapter_params = eval("parse_story_from_#{source.downcase}(content)")
        if @work.nil?
          # create the new work
          @work = Work.new(work_params.merge!(chapter_params))
        else
          @work.chapters << get_chapter_from_work_params(chapter_params)
        end
      end
      return @work
    end

    def get_chapter_from_work_params(work_params)
      @chapter = Chapter.new({:content => work_params[:chapter_attributes][:content]})
      chapter_params = work_params.delete_if {|name, param| !@chapter.attribute_names.include?(name)}
      @chapter.update_attributes(chapter_params)
      return @chapter
    end
    
    def download_text(location)
      story = ""
      source = get_source_if_known(KNOWN_STORY_LOCATIONS, location)
      if source.nil?
        story = Net::HTTP.get(URI.parse(location))
      else
        story = eval("download_from_#{source.downcase}(location)")
      end
      return story      
    end
  
    def parse_text(story, location = nil)
      work_params = { :title => "UPLOADED WORK", :chapter_attributes => {:content => ""} }
      @doc = Hpricot(story)

      if !location.nil?
        source = get_source_if_known(KNOWN_STORY_PARSERS, location)
        if !source.nil?
          params = eval("parse_story_from_#{source.downcase}(story)")
          return work_params.merge!(params)
        end
      end    
      return work_params.merge!(parse_story_from_unknown(story))
    end

    # canonicalize the url for downloading from lj or clones
    def download_from_lj(location)
      url = location
      url.gsub!(/\?(.*)$/, "") # strip off any existing params at the end
      url += "?format=light" # go to light format
      return Net::HTTP.get(URI.parse(url))
    end
    
    # grab all the chapters of the story from ff.net
    def download_chaptered_from_ffnet(location)
      @chapter_contents = []
      if location.match(/^(.*fanfiction\.net\/s\/[0-9]+\/)([0-9]+)(\/.*)$/i)
        urlstart = $1
        urlend = $3       
        chapnum = 1
        loop do
          url = "#{urlstart}#{chapnum.to_s}#{urlend}"
          body = Net::HTTP.get(URI.parse(url))
          if body.empty?
            break
          end
          @chapter_contents << body
          chapnum = chapnum + 1
        end
      end
      return @chapter_contents      
    end
  
    # our fallback: parse a story from an unknown source, so we have no special
    # rules. 
    def parse_story_from_unknown(story)
      work_params = {:chapter_attributes => {}}
      storytext = (@doc/"body").inner_html
      if storytext.empty?
        storytext = (@doc/"html").inner_html
      end
      if storytext.empty?
        # just grab everything
        storytext = story
      end
      meta = scan_text_for_meta(storytext)
      work_params[:title] = (@doc/"title").inner_html    
      work_params[:chapter_attributes][:content] = clean_storytext(storytext)
      work_params = work_params.merge!(meta)
      
      return work_params
    end
  
    def parse_story_from_lj(story)
      work_params = {:chapter_attributes => {}}
      
      # in LJ "light" format, the story contents are in the first div 
      # inside the body.
      body = (@doc/"body")
      content_divs = (body/"div")
      storytext = !content_divs[0].nil? ? content_divs[0].inner_html : body.inner_html
  
      # cleanup the text
      # storytext.gsub!(/<br\s*\/?>/i, "\n") # replace the breaks with newlines
      storytext = clean_storytext(storytext)
      
      work_params[:chapter_attributes][:content] = storytext
      work_params[:title] = (@doc/"title").inner_html # default
      work_params.merge!(scan_text_for_meta(storytext))
      
      return work_params
    end
  
    def parse_story_from_yuletide(story)    
      work_params = {:chapter_attributes => {}}
      storytext = (@doc/"/html/body/p/table/tr/td[2]/table/tr/td[2]").inner_html
      if storytext.empty?
        storytext = (@doc/"body").inner_html
      end
      storytext = clean_storytext(storytext)
  
      # fix the relative links
      storytext.gsub!(/<a href="\//, '<a href="http://yuletidetreasure.org/')
      
      work_params.merge!(scan_text_for_meta(storytext))
      work_params[:chapter_attributes][:content] = storytext
      work_params[:title] = (@doc/"title").inner_html
      work_params[:notes] = (@doc/"/html/body/p/table/tr/td[2]/table/tr/td[2]/center/p").inner_html
      
      tags = ['yuletide']
      if storytext.match(/Fandom: <(.*)>(.*)<\/a>/i)
        fandom_tag = $2
        if TagCategory.official.collect(&:name).include?("Fandom")
          work_params[:Fandom] = fandom_tag
        else
          tags << "fandom:#{fandom_tag}"
        end
      end

      if storytext.match(/Written for: (.*) in the (.*) challenge/i)
        recip = $1
        challenge = $2
        tags << "recipient:#{recip}"
        tags << "challenge:#{challenge}"
      end
      if storytext.match(/<center>.*Fandom:.*Written for:.*by <a .*>(.*)<\/a><br>\n<p>(.*)<\/p><\/center>/ix)
        author = $1
        work_params[:notes] = $2
      end
      
      search_title = work_params[:title].gsub(/[^\w]/, ' ').gsub(/\s+/, '+')
      search_author = author.nil? ? "" : author.gsub(/[^\w]/, ' ').gsub(/\s+/, '+')
      search_recip = recip.nil? ? "" : recip.gsub(/[^\w]/, ' ').gsub(/\s+/, '+')
      search_url = "http://www.yuletidetreasure.org/cgi-bin/search.cgi?" + 
                    "Recipient=#{search_recip}&Title=#{search_title}&Author=#{search_author}&NumToList=0"
      search_res = Net::HTTP.get(URI.parse(search_url))
      search_doc = Hpricot(search_res)
      summary = ""
      rating = ""
      (search_doc/"dd").each do |dd|
        if dd.attributes['class'] == 'summary'
          summary = dd.inner_html
          if summary.gsub!(/<span="rating">\(Rated\s*([\w\-]+)\)/i, '')
            rating = $1
          end
          break
        end
      end
      
      work_params[:summary] = summary
      if TagCategory.official.collect(&:name).include?("Rating")
        case rating
        when "NC-17"
          work_params[:Rating] = "Explicit"
        when "R"
          work_params[:Rating] = "Mature"
        when "PG-13"
          work_params[:Rating] = "Teen and Up"
        when "PG"
          work_params[:Rating] = "General Audience"
        when "G"
          work_params[:Rating] = "General Audience"
        end
      else
        tags << "rating:#{rating}"
      end
      
      work_params[:default] = tags.join(ArchiveConfig.DELIMITER)
      
      return work_params
    end

    def parse_story_from_ffnet(story)
      work_params = {:chapter_attributes => {}}      
      storytext = clean_storytext((@doc/"#storytext").to_html)
      # put in some blank lines to make it readable in the textarea
      # the processing will strip out the extras 
      storytext.gsub!(/<\/p><p>/, "</p>\n\n<p>")
      
      pagetitle = (@doc/"title").inner_html
      if pagetitle && pagetitle.match(/(.*), a (.*) fanfic - FanFiction\.Net/)
        work_params[:title] = $1
        work_params[:Fandom] = $2
      end
      
      work_params[:chapter_attributes][:content] = storytext    
      
      return work_params
    end

    # Find any cases of the given pieces of meta in the given text 
    # and return a hash
    def scan_text_for_meta(text)
      meta = {}
      metapatterns = META_PATTERNS
      # add in all the official tags
      TagCategory.official.each do |c|
        metapatterns.merge!({c.name.to_sym => c.display_name.singularize})
      end
      metapatterns.each do |metaname, pattern|
        # what this does is look for pattern: (whatever) 
        # and then sets meta[:metaname] = whatever
        # eg, if it finds Author: Blah The Great it will set meta[:author] = Blah The Great
        metapattern = Regexp.new("#{pattern}\s*:\s*(.*)", Regexp::IGNORECASE)
        metapattern_plural = Regexp.new("#{pattern.pluralize}\s*:\s*(.*)", Regexp::IGNORECASE)
        if text.match(metapattern) || text.match(metapattern_plural)
          meta[metaname] = $1
        end        
      end      
      return meta
    end

    def clean_storytext(storytext)
      return sanitize_whitelist(cleanup_and_format(storytext))
    end

end