class StoryParser
  require 'hpricot'
  include HtmlFormatter
  
  META_PATTERNS = {:title => 'Title', :notes => 'Note', :summary => 'Summary'}

  KNOWN_STORY_LOCATIONS = %w(lj ffnet)
  LOCATION_LJ = '(live|dead|insane)?journal(fen)?\.com'
  LOCATION_FFNET = 'fanfiction\.net'
  
  # This will stop with the first one it matches, so put more-specific matches
  # towards the front of the list. 
  KNOWN_STORY_SOURCES = %w(lj yuletide ffnet)
  SOURCE_LJ = '(live|dead|insane)?journal(fen)?\.com'
  SOURCE_YULETIDE = 'yuletidetreasure\.org'
  SOURCE_FFNET = 'fanfiction\.net'

  # Downloads a story and passes it on to the parser. 
  # If the URL of the story is from a site for which we have special rules 
  # (eg, downloading from a livejournal clone, you want to use ?format=light
  # to get a nice and consistent post format), it will pre-process the url
  # according to the rules for that site. 
  def download_and_parse_story(location)
    story = ""
    unmatched = true
    KNOWN_STORY_LOCATIONS.each do |source|
      pattern = Regexp.new(eval("LOCATION_#{source.upcase}"), Regexp::IGNORECASE)
      if unmatched && location.match(pattern)
        story = eval("download_from_#{source.downcase}(location)")
        unmatched = false
      end
    end

    if unmatched
      story = Net::HTTP.get(URI.parse(location))
    end

    return parse_story(story, location)
  end

  # Parses the text of a story, optionally from a given location. 
  def parse_story(story, location = nil)
    @work_params = { :title => "UPLOADED WORK", :chapter_attributes => {:content => ""} }
    @doc = Hpricot(story)
    unmatched = true
    
    if !location.nil?
      KNOWN_STORY_SOURCES.each do |source|
        pattern = Regexp.new(eval("SOURCE_#{source.upcase}"), Regexp::IGNORECASE)
        if unmatched && location.match(pattern)
          @work_params = eval("parse_story_from_#{source.downcase}(story)")
          unmatched = false
        end
      end
    end    
    if unmatched
      @work_params = parse_story_from_unknown(story)
    end    
    return Work.new(@work_params)
  end

  # Everything below here is protected and should not be touched by outside
  # code -- please use the above functions to parse stories. 

  protected

    # canonicalize the url for downloading from lj or clones
    def download_from_lj(location)
      url = location
      url.gsub!(/\?(.*)$/, "") # strip off any existing params at the end
      url += "?format=light" # go to light format
      return Net::HTTP.get(URI.parse(url))
    end
    
    # grab all the chapters of the story from ff.net
    def download_from_ffnet(location)
      content = ""
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
          doc = Hpricot(body)
          content += ((doc/"title").to_html + (doc/"#storytext").to_html)
          chapnum = chapnum + 1
        end
      end
      return content      
    end
  
    # our fallback: parse a story from an unknown source, so we have no special
    # rules. 
    def parse_story_from_unknown(story)
      storytext = (@doc/"body").inner_html
      if storytext.empty?
        storytext = (@doc/"html").inner_html
      end
      meta = scan_text_for_meta(storytext)
      
      @work_params[:title] = (@doc/"title").inner_html    
      @work_params[:chapter_attributes][:content] = clean_storytext(storytext)
      @work_params = @work_params.merge!(meta)
      
      return @work_params
    end
  
    def parse_story_from_lj(story)
      # in LJ "light" format, the story contents are in the first div 
      # inside the body.
      body = (@doc/"body")
      content_divs = (body/"div")
      storytext = !content_divs[0].nil? ? content_divs[0].inner_html : body.inner_html
  
      # cleanup the text
      # storytext.gsub!(/<br\s*\/?>/i, "\n") # replace the breaks with newlines
      storytext = clean_storytext(storytext)
      
      @work_params[:chapter_attributes][:content] = storytext
      @work_params[:title] = (@doc/"title") # default
      @work_params.merge!(scan_text_for_meta(storytext))
      
      return @work_params
    end
  
    def parse_story_from_yuletide(story)    
      storytext = (@doc/"/html/body/p/table/tr/td[2]/table/tr/td[2]").inner_html
      if storytext.empty?
        storytext = (@doc/"body").inner_html
      end
      storytext = clean_storytext(storytext)
  
      # fix the relative links
      storytext.gsub!(/<a href="\//, '<a href="http://yuletidetreasure.org/')
      
      @work_params.merge!(scan_text_for_meta(storytext))
      @work_params[:chapter_attributes][:content] = storytext
      @work_params[:title] = (@doc/"title").inner_html
      @work_params[:notes] = (@doc/"/html/body/p/table/tr/td[2]/table/tr/td[2]/center/p").inner_html
      
      return @work_params
    end

    def parse_story_from_ffnet(story)
      storytext = clean_storytext(story)
      # put in some blank lines to make it readable in the textarea
      # the processing will strip out the extras 
      storytext.gsub!(/<\/p><p>/, "</p>\n\n<p>")
      
      pagetitle = (@doc/"title").first.inner_html
      if pagetitle && pagetitle.match(/(.*), a (.*) fanfic - FanFiction\.Net/)
        @work_params[:title] = $1
        @work_params[:Fandom] = $2
      end
      
      @work_params[:chapter_attributes][:content] = storytext    
      
      return @work_params
    end

    # Find any cases of the given pieces of meta in the given text 
    # and return a hash
    def scan_text_for_meta(text)
      meta = {}
      metapatterns = META_PATTERNS
      # add in all the tags -- COmmented out until works are fixed -- NN
      TagCategory.official.each do |c|
        metapatterns.merge!({c.name.to_sym => c.name.singularize})
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