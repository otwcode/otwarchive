class StoryParser
  require 'hpricot'
  include HtmlFormatter
  
  META_PATTERNS = {:title => 'Title', :notes => 'Note', :summary => 'Summary'}

  KNOWN_STORY_LOCATIONS = %w(lj)
  LOCATION_LJ = '(live|dead|insane)?journal(fen)?\.com'
  
  # This will stop with the first one it matches, so put more-specific matches
  # towards the front of the list. 
  KNOWN_STORY_SOURCES = %w(lj yuletide)
  SOURCE_LJ = '(live|dead|insane)?journal(fen)?\.com'
  SOURCE_YULETIDE = 'yuletidetreasure\.org'

  def download_and_parse_story(location)
    url = location
    KNOWN_STORY_LOCATIONS.each do |source|
      pattern = Regexp.new(eval("LOCATION_#{source.upcase}"), Regexp::IGNORECASE)

      if location.match(pattern)
        url = eval("url_from_#{source.downcase}(location)")
      end
    end

    return parse_story(Net::HTTP.get(URI.parse(url)), location)
  end

  # canonicalize the url for downloading from lj or clones
  def url_from_lj(location)
    url = location
    url.gsub!(/\?(.*)$/, "") # strip off any existing params at the end
    url += "?format=light" # go to light format
    return url
  end

  def parse_story(story, location)
    @work_params = { :title => "UPLOADED WORK", :chapter_attributes => {:content => ""} }
    @doc = Hpricot(story)
    unmatched = true
    
    KNOWN_STORY_SOURCES.each do |source|
      pattern = Regexp.new(eval("SOURCE_#{source.upcase}"), Regexp::IGNORECASE)
      if unmatched && location.match(pattern)
        @work_params = eval("parse_story_from_#{source.downcase}(story)")
        unmatched = false
      end
    end
    if unmatched
      @work_params = parse_story_from_unknown(story)
    end
    
    return Work.new(@work_params)
  end

  def parse_story_from_unknown(story)
    storytext = (@doc/"body").inner_html
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

  protected
  
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
        puts "m: #{metaname}, p: #{pattern}"
        # what this does is look for pattern: (whatever) 
        # and then sets meta[:metaname] = whatever
        # eg, if it finds Author: Blah The Great it will set meta[:author] = Blah The Great
        metapattern = Regexp.new("#{pattern}\s*:\s*(.*)", Regexp::IGNORECASE)
        metapattern_plural = Regexp.new("#{pattern.pluralize}\s*:\s*(.*)", Regexp::IGNORECASE)
        if text.match(metapattern) || text.match(metapattern_plural)
          puts "match #{metapattern.to_s}, #{$1}"
          meta[metaname] = $1
        end        
      end      
      return meta
    end

    def clean_storytext(storytext)
      return sanitize_whitelist(cleanup_and_format(storytext))
    end

end