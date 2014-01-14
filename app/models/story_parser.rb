# Parse stories from other websites and uploaded files, looking for metadata to harvest
# and put into the archive.
#
class StoryParser
  require 'timeout'
  require 'nokogiri'
  require 'mechanize'
  require 'open-uri'
  include HtmlCleaner

  META_PATTERNS = {:title => 'Title',
                   :notes => 'Note',
                   :summary => 'Summary',
                   :freeform_string => "Tag",
                   :fandom_string => "Fandom",
                   :rating_string => "Rating",
                   :relationship_string => "Relationship|Pairing",
                   :revised_at => 'Date|Posted|Posted on|Posted at'
                   }


  # Use this for raising custom error messages
  # (so that we can distinguish them from unexpected exceptions due to
  # faulty code)
  class Error < StandardError
  end
  
  # These attributes need to be moved from the work to the chapter
  # format: {:work_attribute_name => :chapter_attribute_name} (can be the same)
  CHAPTER_ATTRIBUTES_ONLY = {}

  # These attributes need to be copied from the work to the chapter
  CHAPTER_ATTRIBUTES_ALSO = {:revised_at => :published_at}

  ### NOTE ON KNOWN SOURCES
  # These lists will stop with the first one it matches, so put more-specific matches
  # towards the front of the list.

  # places for which we have a custom parse_story_from_[source] method
  # for getting information out of the downloaded text
  KNOWN_STORY_PARSERS = %w(deviantart dw lj yuletide ffnet lotrfanfiction twilightarchives)

  # places for which we have a custom parse_author_from_[source] method
  # which returns an external_author object including an email address
  KNOWN_AUTHOR_PARSERS= %w(yuletide lj minotaur)

  # places for which we have a download_story_from_[source]
  # used to customize the downloading process
  KNOWN_STORY_LOCATIONS = %w(lj)

  # places for which we have a download_chaptered_from
  # to get a set of chapters all together
  CHAPTERED_STORY_LOCATIONS = %w(ffnet efiction)

  # regular expressions to match against the URLS
  SOURCE_LJ = '((live|dead|insane)?journal(fen)?\.com)|dreamwidth\.org'
  SOURCE_DW = 'dreamwidth\.org'
  SOURCE_YULETIDE = 'yuletidetreasure\.org'
  SOURCE_FFNET = '(^|[^A-Za-z0-9-])fanfiction\.net'
  SOURCE_MINOTAUR = '(bigguns|firstdown).slashdom.net'
  SOURCE_DEVIANTART = 'deviantart\.com'
  SOURCE_LOTRFANFICTION = 'lotrfanfiction\.com'
  SOURCE_TWILIGHTARCHIVES = 'twilightarchives\.com'
  SOURCE_EFICTION = 'viewstory\.php'

  # time out if we can't download fast enough
  STORY_DOWNLOAD_TIMEOUT = 60
  MAX_CHAPTER_COUNT = 200


  # Import many stories
  def import_from_urls(urls, options = {})
    # Try to get the works
    works = []
    failed_urls = []
    errors = []
    urls.each do |url|
      begin
        work = download_and_parse_story(url, options)
        if work && work.save
          work.chapters.each {|chap| chap.save}
          works << work
        else
          failed_urls << url
          errors << work.errors.values.join(", ")
          work.delete if work
        end
      rescue Timeout::Error
        failed_urls << url
        errors << "Import has timed out. This may be due to connectivity problems with the source site. Please try again in a few minutes, or check Known Issues to see if there are import problems with this site."
        work.delete if work        
      rescue Error => exception
        failed_urls << url
        errors << "We couldn't successfully import that work, sorry: #{exception.message}"
        work.delete if work
      end
    end
    return [works, failed_urls, errors]
  end


  ### DOWNLOAD-AND-PARSE WRAPPERS

  # General pathway for story importing:
  #
  # Starting points:
  # - import_from_urls --> repeatedly calls download_and_parse_story
  # - download_and_parse_story
  # - download_and_parse_chapters_into_story
  # - (download_and_parse_chapter_of_work -- requires existing work)
  #
  # Each of these will download the content and then hand it off to a parser.
  #
  # Parsers:
  # - parse_story: for a work of one single chapter downloaded as a single text string
  # - parse_chapters_into_story: for a work of multiple chapters downloaded as an array of text strings (the separate chapter contents)
  # - parse_chapter_of_work: essentially duplicates parse_story, but turns the content into a chapter of an existing work
  #
  # All of these parsers then go into
  # - parse_common: processes a single text string, cleaning up HTML and looking for meta information
  # - sanitize_params: after processing, clean up the params and strip out bad HTML
  #
  # If the story is from a known source, parse_common hands off to a custom parser built just for that source,
  # including parse_story_from_yuletide, parse_story_from_lj, parse_story_from_ffnet. If not known, it falls
  # back on parse_story_from_unknown.
  #
  # The various parsers use different methods to collect up metadata, and generically we also use:
  # - scan_text_for_meta: looks for text patterns like [metaname]: [value] eg, "Fandom: Highlander"
  #
  # Shared options:
  #
  # :do_not_set_current_author - true means do not save the current user as an author
  # :importing for others - true means try and add external author for the work
  # :pseuds - a list of pseuds to set as authors
  # :set_tags, :fandom, :rating, :warning, :character, :relationship - sets these tags
  # :override_tags - set tag values even if some were parsed out of the work
  # :post_without_preview - if true, mark the story as posted without previewing
  #



  # Downloads a story and passes it on to the parser.
  # If the URL of the story is from a site for which we have special rules
  # (eg, downloading from a livejournal clone, you want to use ?format=light
  # to get a nice and consistent post format), it will pre-process the url
  # according to the rules for that site.
  def download_and_parse_story(location, options = {})
    check_for_previous_import(location)
    work = nil
    source = get_source_if_known(CHAPTERED_STORY_LOCATIONS, location)
    if source.nil?
      story = download_text(location)
      work = parse_story(story, location, options)
    else
      work = download_and_parse_chaptered_story(source, location, options)
    end
    return work
  end

  # download and add a new chapter to the end of a work
  def download_and_parse_chapter_of_work(work, location, options = {})
    chapter_content = download_text(location)
    return parse_chapter_of_work(work, chapter_content, location, options)
  end

  # Given an array of urls for chapters of a single story,
  # download them all and combine into a single work
  def download_and_parse_chapters_into_story(locations, options = {})
    check_for_previous_import(locations.first)
    chapter_contents = []
    locations.each do |location|
      chapter_contents << download_text(location)
    end
    return parse_chapters_into_story(locations.first, chapter_contents, options)
  end

  ### PARSING METHODS

  # Parses the text of a story, optionally from a given location.
  def parse_story(story, location, options = {})
    work_params = parse_common(story, location, options[:encoding])

    # move any attributes from work to chapter if necessary
    return set_work_attributes(Work.new(work_params), location, options)
  end

  # parses and adds a new chapter to the end of the work
  def parse_chapter_of_work(work, chapter_content, location, options = {})
    tmp_work_params = parse_common(chapter_content, location, options[:encoding])
    chapter = get_chapter_from_work_params(tmp_work_params)
    work.chapters << set_chapter_attributes(work, chapter, location, options)
    return work
  end

  def parse_chapters_into_story(location, chapter_contents, options = {})
    work = nil
    chapter_contents.each do |content|
      work_params = parse_common(content, location, options[:encoding])
      if work.nil?
        # create the new work
        work = Work.new(work_params)
      else
        new_chapter = get_chapter_from_work_params(work_params)
        work.chapters << set_chapter_attributes(work, new_chapter, location, options)
      end
    end
    return set_work_attributes(work, location, options)
  end

  # tries to create an external author for a given url
  def parse_author(location,external_author_name,external_author_email)
    #If e_email option value is present (archivist importing from somewhere not supported for auto autho grab)
    #will have value there, otherwise continue as usual. If filled, just pass values to create or find external author
    #Stephanie 8-1-2013

    #might want to add check for external author name also here, steph 12/10/2013
    if external_author_email.present?
      return parse_author_common(external_author_email,external_author_name)

    else
      source = get_source_if_known(KNOWN_AUTHOR_PARSERS, location)
      if !source.nil?
        return eval("parse_author_from_#{source.downcase}(location)")
      end
      return parse_author_from_unknown(location)

    end

  end


  # Everything below here is protected and should not be touched by outside
  # code -- please use the above functions to parse external works.

  #protected


    # download an entire story from an archive type where we know how to parse multi-chaptered works
    # this should only be called from download_and_parse_story
    def download_and_parse_chaptered_story(source, location, options = {})
      chapter_contents = eval("download_chaptered_from_#{source.downcase}(location)")
      return parse_chapters_into_story(location, chapter_contents, options)
    end


    #Updated as elz suggested now getting www and non www, Stephanie 1-11-2014
    def check_for_previous_import(location)
      urls = [location, location.gsub('www.', '')].uniq
      if Work.where(imported_from_url: urls).exists?
        raise Error, "A work has already been imported from #{location}."
      end
    end


    def set_chapter_attributes(work, chapter, location, options = {})
      chapter.position = work.chapters.length + 1
      chapter.posted = true # if options[:post_without_preview]
      return chapter
    end

    def set_work_attributes(work, location="", options = {})
      raise Error, "Work could not be downloaded" if work.nil?
      work.imported_from_url = location
      work.expected_number_of_chapters = work.chapters.length

      # set authors for the works
      pseuds = []
      pseuds << User.current_user.default_pseud unless options[:do_not_set_current_author] || User.current_user.nil?
      pseuds << options[:archivist].default_pseud if options[:archivist]
      pseuds += options[:pseuds] if options[:pseuds]
      pseuds = pseuds.uniq
      raise Error, "A work must have at least one author specified" if pseuds.empty?
      pseuds.each do |pseud|
        work.pseuds << pseud unless work.pseuds.include?(pseud)
        work.chapters.each {|chapter| chapter.pseuds << pseud unless chapter.pseuds.include?(pseud)}
      end

      # handle importing works for others
      # build an external creatorship for each author
      if options[:importing_for_others]
        external_author_names = options[:external_author_names] || parse_author(location,options[:external_author_name],options[:external_author_email])
        # convert to an array if not already one
        external_author_names = [external_author_names] if external_author_names.is_a?(ExternalAuthorName)
        if options[:external_coauthor_name] != nil
          external_author_names << parse_author(location,options[:external_coauthor_name],options[:external_coauthor_email])
        end
        external_author_names.each do |external_author_name|
          if external_author_name && external_author_name.external_author
            if external_author_name.external_author.do_not_import
              # we're not allowed to import works from this address
              raise Error, "Author #{external_author_name.name} at #{external_author_name.external_author.email} does not allow importing their work to this archive."
            end
            ec = work.external_creatorships.build(:external_author_name => external_author_name, :archivist => (options[:archivist] || User.current_user))
          end
        end
      end

      # lock to registered users if specified or importing for others
      work.restricted = options[:restricted] || options[:importing_for_others] || false

      # set default values for required tags for any works that don't have them
      work.fandom_string = (options[:fandom].blank? ? ArchiveConfig.FANDOM_NO_TAG_NAME : options[:fandom]) if (options[:override_tags] || work.fandoms.empty?)
      work.rating_string = (options[:rating].blank? ? ArchiveConfig.RATING_DEFAULT_TAG_NAME : options[:rating]) if (options[:override_tags] || work.ratings.empty?)
      work.warning_strings = (options[:warning].blank? ? ArchiveConfig.WARNING_DEFAULT_TAG_NAME : options[:warning]) if (options[:override_tags] || work.warnings.empty?)
      work.category_string = options[:category] if !options[:category].blank? && (options[:override_tags] || work.categories.empty?)
      work.character_string = options[:character] if !options[:character].blank? && (options[:override_tags] || work.characters.empty?)
      work.relationship_string = options[:relationship] if !options[:relationship].blank? && (options[:override_tags] || work.relationships.empty?)
      work.freeform_string = options[:freeform] if !options[:freeform].blank? && (options[:override_tags] || work.freeforms.empty?)

      # set default value for title
      work.title = "Untitled Imported Work" if work.title.blank?

      work.posted = true if options[:post_without_preview]
      work.chapters.each do |chapter|
        if chapter.content.length > ArchiveConfig.CONTENT_MAX
          # TODO: eventually: insert a new chapter
          chapter.content.truncate(ArchiveConfig.CONTENT_MAX, :omission => "<strong>WARNING: import truncated automatically because chapter was too long! Please add a new chapter for remaining content.</strong>", :separator => "</p>")
        end
        
        chapter.posted = true
        # ack! causing the chapters to exist even if work doesn't get created!
        # chapter.save
      end
      return work
    end

    def parse_author_from_yuletide(location)
      if location.match(/archive\/([0-9]+\/.*)\.html/)
        yuletide_location = $1
        archive_url = "http://yuletidetreasure.org/cgi-bin/files/get_author.cgi?filename=#{yuletide_location}"
        author_info = download_text(archive_url)
        email = name = ""
        if author_info.match(/^EMAIL: (.*)$/)
          email = $1
        end
        if author_info.match(/^NAME: (.*)/)
          name = $1
        end
        return parse_author_common(email, name)
      end
    end

    def parse_author_from_lj(location)
      if location.match( /^(http:\/\/)?([^\.]*).(livejournal.com|dreamwidth.org|insanejournal.com|journalfen.net)/)
        email = name = ""
        lj_name = $2
        site_name = $3
        if lj_name == "community"
          # whups
          post_text = download_text(location)
          doc = Nokogiri.parse(post_text)
          lj_name = doc.xpath("/html/body/div[2]/div/div/div/table/tbody/tr/td[2]/span/a[2]/b").content
        end
        profile_url = "http://#{lj_name}.#{site_name}/profile"
        lj_profile = download_text(profile_url)
        doc = Nokogiri.parse(lj_profile)
        contact = doc.css('div.contact').inner_html
        contact.gsub! '<p class="section_body_title">Contact:</p>', ""
        contact.gsub! /<\/?(span|i)>/, ""
        contact.gsub! /\n/, ""
        contact.gsub! /<br\/>/, ""
        if contact.match(/(.*@.*\..*)/)
          email = $1
        end
        if email.blank?
          email = "#{lj_name}@#{site_name}"
        end
        return parse_author_common(email, lj_name)
      end
    end

    def parse_author_from_unknown(location)
      # for now, nothing
      return nil
    end

    # custom author parser for the whitfic and grahamslash archives we're rescuing
    # known problem: this will only find the first author for a given story, not coauthors
    def parse_author_from_minotaur(location)
      # get the index page of the archive
      # and the relative link for story we are downloading
      if location =~ /firstdown/
        author_index = download_text("http://firstdown.slashdom.net/authors.html")
        storylink = location.gsub("http://firstdown.slashdom.net/", "")
      elsif location =~ /bigguns/
        author_index = download_text("http://bigguns.slashdom.net/stories/authors.html")
        storylink = location.gsub("http://bigguns.slashdom.net/stories/", "")
      end
      doc = Nokogiri.parse(author_index)

      # find the author just before the story
      doc.search("a").each do |node|
        if node[:href] =~ /mailto:(.*)/
          authornode = node
        end
        if node[:href] == storylink
          # the last-found authornode is the right one
          break
        end
      end
      email = authornode[:href].gsub("mailto:", '')
      name = authornode.inner_text

      return parse_author_common(email, name)
    end

    def parse_author_common(email, name)
      external_author = ExternalAuthor.find_or_create_by_email(email)
      unless name.blank?
        external_author_name = ExternalAuthorName.find(:first, :conditions => {:name => name, :external_author_id => external_author.id}) ||
                                  ExternalAuthorName.new(:name => name)
        external_author.external_author_names << external_author_name
        external_author.save
      end
      return external_author_name || external_author.default_name
    end

    def get_chapter_from_work_params(work_params)
      @chapter = Chapter.new(work_params[:chapter_attributes])
      # don't override specific chapter params (eg title) with work params  
      chapter_params = work_params.delete_if {|name, param| !@chapter.attribute_names.include?(name.to_s) || !@chapter.send(name.to_s).blank?}
      @chapter.update_attributes(chapter_params)
      return @chapter
    end

    def download_text(location)
      story = ""
      source = get_source_if_known(KNOWN_STORY_LOCATIONS, location)
      if source.nil?
        story = download_with_timeout(location)
      else
        story = eval("download_from_#{source.downcase}(location)")
      end

      # clean up any erroneously included string terminator (Issue 785)
      story = story.gsub("\000", "")
      
      #story = fix_bad_characters(story)
      # ^ This eats ALL special characters. I don't think we need it at all
      # so I'm taking it out. If we want it back, it should be the last
      # thing we do with the parsed bits after Nokogiri has parsed the content
      # and worked it's magic with encoding --rebecca
      return story
    end

    # canonicalize the url for downloading from lj or clones
    def download_from_lj(location)
      url = location
      url.gsub!(/\#(.*)$/, "") # strip off any anchor information
      url.gsub!(/\?(.*)$/, "") # strip off any existing params at the end
      url.gsub!('_', '-') # convert underscores in usernames to hyphens
      url += "?format=light" # go to light format
      text = download_with_timeout(url)
      if text.match(/adult_check/)
        Timeout::timeout(STORY_DOWNLOAD_TIMEOUT) {
          begin
            agent = Mechanize.new
            form = agent.get(url).forms.first
            page = agent.submit(form, form.buttons.first) # submits the adult concepts form
            text = page.body.force_encoding(agent.page.encoding)
          rescue
            text = ""
          end
        }
      end
      return text
    end

    # grab all the chapters of the story from ff.net
    def download_chaptered_from_ffnet(location)
      raise Error, "Imports from fanfiction.net are no longer available due to a block on their end. :("
      # raise Error, "We cannot read #{location}. Are you trying to import from the story preview?" if location.match(/story_preview/)
      # raise Error, "The url #{location} is locked." if location.match(/secure/)
      # @chapter_contents = []
      # if location.match(/^(.*fanfiction\.net\/s\/[0-9]+\/)([0-9]+)(\/.*)$/i)
      #   urlstart = $1
      #   urlend = $3
      #   chapnum = 1
      #   Timeout::timeout(STORY_DOWNLOAD_TIMEOUT) {
      #     loop do
      #       url = "#{urlstart}#{chapnum.to_s}#{urlend}"
      #       body = download_with_timeout(url)
      #       if body.nil? || chapnum > MAX_CHAPTER_COUNT || body.match(/FanFiction\.Net Message/)
      #         break
      #       end
      #       @chapter_contents << body
      #       chapnum = chapnum + 1
      #     end
      #   }
      # end
      # return @chapter_contents
    end


    # grab all the chapters of a story from an efiction-based site
    def download_chaptered_from_efiction(location)
      @chapter_contents = []
      if location.match(/^(.*)\/.*viewstory\.php.*sid=(\d+)($|&)/i)
        site = $1
        storyid = $2        
        chapnum = 1
        Timeout::timeout(STORY_DOWNLOAD_TIMEOUT) {
          loop do
            url = "#{site}/viewstory.php?action=printable&sid=#{storyid}&chapter=#{chapnum}"
            body = download_with_timeout(url)
            if body.nil? || chapnum > MAX_CHAPTER_COUNT || body.match(/<div class='chaptertitle'> by <\/div>/) || body.match(/Access denied./) || body.match(/Chapter : /)
              break
            end
            
            @chapter_contents << body
            chapnum = chapnum + 1
          end
        }
      end
      return @chapter_contents
    end


    # This is the heavy lifter, invoked by all the story and chapter parsers.
    # It takes a single string containing the raw contents of a story, parses it with
    # Nokogiri into the @doc object, and then and calls a subparser.
    #
    # If the story source can be identified as one of the sources we know how to parse in some custom/
    # special way, parse_common calls the customized parse_story_from_[source] method.
    # Otherwise, it falls back to parse_story_from_unknown.
    #
    # This produces a hash equivalent to the params hash that is normally created by the standard work
    # upload form.
    #
    # parse_common then calls sanitize_params (which would also be called on the standard work upload
    # form results) and returns the final sanitized hash.
    #
    def parse_common(story, location = nil, encoding = nil)
      work_params = { :title => "UPLOADED WORK", :chapter_attributes => {:content => ""} }

      @doc = Nokogiri::HTML.parse(story, nil, encoding) rescue ""

      if location && (source = get_source_if_known(KNOWN_STORY_PARSERS, location))
        params = eval("parse_story_from_#{source.downcase}(story)")
        work_params.merge!(params)
      else
        work_params.merge!(parse_story_from_unknown(story))
      end

      return shift_chapter_attributes(sanitize_params(work_params))
    end

    # our fallback: parse a story from an unknown source, so we have no special
    # rules.
    def parse_story_from_unknown(story)
      work_params = {:chapter_attributes => {}}
      storyhead = @doc.css("head").inner_html if @doc.css("head")
      storytext = @doc.css("body").inner_html if @doc.css("body")
      if storytext.blank?
        storytext = @doc.css("html").inner_html
      end
      if storytext.blank?
        # just grab everything
        storytext = story
      end
      meta = {}
      unless storyhead.blank?
        meta.merge!(scan_text_for_meta(storyhead))
      end
      meta.merge!(scan_text_for_meta(storytext))
      work_params[:title] = @doc.css("title").inner_html
      work_params[:chapter_attributes][:content] = clean_storytext(storytext)
      work_params = work_params.merge!(meta)

      return work_params
    end

    # Parses a story from livejournal or a livejournal equivalent (eg, dreamwidth, insanejournal)
    # Assumes that we have downloaded the story from one of those equivalents (ie, we've downloaded
    # it in format=light which is a stripped-down plaintext version.)
    #
    def parse_story_from_lj(story)
      work_params = {:chapter_attributes => {}}

      # in LJ "light" format, the story contents are in the second div
      # inside the body.
      body = @doc.css("body")
      storytext = body.css("article.b-singlepost-body").inner_html
      storytext = body.inner_html if storytext.empty?

      # cleanup the text
      # storytext.gsub!(/<br\s*\/?>/i, "\n") # replace the breaks with newlines
      storytext = clean_storytext(storytext)

      work_params[:chapter_attributes][:content] = storytext
      work_params[:title] = @doc.css("title").inner_html
      work_params[:title].gsub! /^[^:]+: /, ""
      work_params.merge!(scan_text_for_meta(storytext))

      date = @doc.css("span.b-singlepost-author-date")
      unless date.empty?
        work_params[:revised_at] = convert_revised_at(date.first.inner_text)
      end

      return work_params
    end

    def parse_story_from_dw(story)
      work_params = {:chapter_attributes => {}}

      body = @doc.css("body")
      content_divs = body.css("div.contents")
      
      unless content_divs[0].nil?
        # Get rid of the DW metadata table
        content_divs[0].css("div.currents, ul.entry-management-links, div.header.inner, span.restrictions, h3.entry-title").each do |node|
          node.remove
        end
        storytext = content_divs[0].inner_html
      else
        storytext = body.inner_html
      end

      # cleanup the text
      # storytext.gsub!(/<br\s*\/?>/i, "\n") # replace the breaks with newlines
      storytext = clean_storytext(storytext)

      work_params[:chapter_attributes][:content] = storytext
      work_params[:title] = @doc.css("title").inner_html
      work_params[:title].gsub! /^[^:]+: /, ""
      work_params.merge!(scan_text_for_meta(storytext))

      font_blocks = @doc.xpath('//font')
      unless font_blocks.empty?
        date = font_blocks.first.inner_text
        work_params[:revised_at] = convert_revised_at(date)
      end

      # get the date
      date = @doc.css("span.date").inner_text
      work_params[:revised_at] = convert_revised_at(date)

      return work_params
    end

    def parse_story_from_deviantart(story)
      work_params = {:chapter_attributes => {}}
      storytext = ""
      notes = ""
      
      body = @doc.css("body")
      title = @doc.css("title").inner_html.gsub /\s*on deviantart$/i, ""

      # Find the image (original size) if it's art
      image_full = body.css("div.dev-view-deviation img.dev-content-full")
      unless image_full[0].nil?
        storytext = "<center><img src=\"#{image_full[0]["src"]}\"></center>"
      end

      # Find the fic text if it's fic (needs the id for disambiguation, the "deviantART loves you" bit in the footer has the same class path)
      text_table = body.css(".grf-indent > div:nth-child(1)")[0]
      unless text_table.nil?
        # Try to remove some metadata (title and author) from the work's text, if possible
        # Try to remove the title: if it exists, and if it's the same as the browser title
        if text_table.css("h1")[0].present? && title && title.match(text_table.css("h1")[0].text)
          text_table.css("h1")[0].remove
        end

        # Try to remove the author: if it exists, and if it follows a certain pattern
        if text_table.css("small")[0].present? && text_table.css("small")[0].inner_html.match(/by ~.*?<a class="u" href=/m)
          text_table.css("small")[0].remove
        end
        storytext = text_table.inner_html
      end
      
      # cleanup the text
      storytext.gsub!(/<br\s*\/?>/i, "\n") # replace the breaks with newlines
      storytext = clean_storytext(storytext)
      work_params[:chapter_attributes][:content] = storytext
        
      # Find the notes
      content_divs = body.css("div.text-ctrl div.text")
      unless content_divs[0].nil?
        notes = content_divs[0].inner_html
      end
        
      # cleanup the notes
      notes.gsub!(/<br\s*\/?>/i, "\n") # replace the breaks with newlines
      notes = clean_storytext(notes)
      work_params[:notes] = notes
        
      work_params.merge!(scan_text_for_meta(notes))
      work_params[:title] = title

      body.css("div.dev-title-container h1 a").each do |node|
        if node["class"] != "u"
          work_params[:title] = node.inner_html
        end
      end

      tags = []
      @doc.css("div.dev-about-cat-cc a.h").each { |node| tags << node.inner_html }
      work_params[:freeform_string] = clean_tags(tags.join(ArchiveConfig.DELIMITER_FOR_OUTPUT))

      details = @doc.css("div.dev-right-bar-content span[title]")
      unless details[0].nil?
         work_params[:revised_at] = convert_revised_at(details[0].inner_text)
      end

      return work_params
    end

    # Parses a story from the Yuletide archive (an AutomatedArchive)
    def parse_story_from_yuletide(story)
      work_params = {:chapter_attributes => {}}
      tags = ['yuletide']

      content_table = (@doc/"table[@class='form']/tr/td[2]")
      
      unless content_table.nil?
        centers = content_table.css("center")

        # Try to parse (and remove) the metadata
        p = /Fandom:\s*?<a .*?>(.*?)<\/a>.*?Written for: (.*) in the (Yuletide|New Year Resolutions) (\d*) Challenge.*?by <a .*?>(.*?)<\/a>/im
        
        if !centers[0].nil? && centers[0].to_html.match(p)

          fandom, recip, challenge, year, author = $1, $2, $3, $4, $5

          work_params[:recipients] = recip

          if challenge=="Yuletide"
            tags << "challenge:Yuletide #{year}"
            work_params[:revised_at] = convert_revised_at("#{year}-12-25")
          else
            tags << "challenge:NYR #{year}"
            work_params[:revised_at] = convert_revised_at("#{year}-01-01")
          end
            
          work_params[:fandom_string] = fandom

          unless centers[0].css("h2")[0].nil?
            work_params[:title] = centers[0].css("h2")[0].inner_html
          else
            work_params[:title] = (@doc/"title").inner_html
          end

          unless centers[0].css("p")[0].nil?
            work_params[:notes] = centers[0].css("p")[0].inner_html
          end
          
          centers[0].remove
        end
        
        # Try to remove the comment links at the bottom
        if !centers[-1].nil? && centers[-1].to_html.match(/<!-- COMMENTLINK START -->/)
          centers[-1].remove
        end
        
        storytext = content_table.inner_html
        
      else
        storytext = (@doc/"body").inner_html
        work_params[:title] = (@doc/"title").inner_html
      end
      
      storytext = clean_storytext(storytext)

      # fix the relative links
      storytext.gsub!(/<a href="\//, '<a href="http://yuletidetreasure.org/')

      work_params.merge!(scan_text_for_meta(storytext))
      work_params[:chapter_attributes][:content] = storytext

      # Here we're going to try and get the search results
      begin
        search_title = work_params[:title].gsub(/[^\w]/, ' ').gsub(/\s+/, '+')
        search_author = author.nil? ? "" : author.gsub(/[^\w]/, ' ').gsub(/\s+/, '+')
        search_recip = recip.nil? ? "" : recip.gsub(/[^\w]/, ' ').gsub(/\s+/, '+')
        search_url = "http://www.yuletidetreasure.org/cgi-bin/search.cgi?" +
                      "Recipient=#{search_recip}&Title=#{search_title}&Author=#{search_author}&NumToList=0"
        search_res = download_with_timeout(search_url)
        search_doc = Nokogiri.parse(search_res)
        summary = search_doc.css('dd.summary') ? search_doc.css('dd.summary').first.content : ""
        work_params[:summary] = summary
        work_params.merge!(scan_text_for_meta(search_res))
      rescue
        # couldn't get the summary data, oh well, keep going
      end

      work_params[:freeform_string] = clean_tags(tags.join(ArchiveConfig.DELIMITER_FOR_OUTPUT))

      return work_params
    end

    # Parses a story from fanfiction.net
    def parse_story_from_ffnet(story)
      work_params = {:chapter_attributes => {}}
      # storytext = clean_storytext((@doc/"#storytext").inner_html)
      storytext = (@doc/"#storytext")
      #remove share area
      divs = storytext.css("div div.a2a_kit")
      if !divs[0].nil?
        divs[0].remove
      end
      storytext = clean_storytext(storytext.inner_html)

      work_params[:notes] = ((@doc/"#storytext")/"p").first.try(:inner_html)

      # put in some blank lines to make it readable in the textarea
      # the processing will strip out the extras
      storytext.gsub!(/<\/p><p>/, "</p>\n\n<p>")

      tags = []
      pagetitle = (@doc/"title").inner_html
      if pagetitle && pagetitle.match(/(.*), an? (.*) fanfic/)
        work_params[:fandom_string] = $2
        work_params[:title] = $1
        if work_params[:title].match(/^(.*) Chapter ([0-9]+): (.*)$/)
          work_params[:title] = $1
          work_params[:chapter_attributes][:title] = $3
        end
      end
      if story.match(/rated:\s*<a.*?>\s*(.*?)<\/a>/i)
        rating = convert_rating($1)
        work_params[:rating_string] = rating
      end

      if story.match(/published:\s*(\d\d)-(\d\d)-(\d\d)/i)
        date = convert_revised_at("#{$3}/#{$1}/#{$2}")
        work_params[:revised_at] = date
      end

      if story.match(/rated.*?<\/a> - .*? - (.*?)(\/(.*?))? -/i)
        tags << $1
        tags << $3 unless $1 == $3
      end

      work_params[:freeform_string] = clean_tags(tags.join(ArchiveConfig.DELIMITER_FOR_OUTPUT))
      work_params[:chapter_attributes][:content] = storytext

      return work_params
    end

    def parse_story_from_lotrfanfiction(story)
      work_params = parse_story_from_modified_efiction(story, "lotrfanfiction")
      work_params[:fandom_string] = "Lord of the Rings"
      return work_params      
    end
    
    def parse_story_from_twilightarchives(story)
      work_params = parse_story_from_modified_efiction(story, "twilightarchives")
      work_params[:fandom_string] = "Twilight"      
      return work_params      
    end
    
    def parse_story_from_modified_efiction(story, site = "")
      work_params = {:chapter_attributes => {}}
      storytext = @doc.css("div.chapter").inner_html
      storytext = clean_storytext(storytext)
      work_params[:chapter_attributes][:content] = storytext
      
      work_params[:title] = @doc.css("html body div#pagetitle a").first.inner_text.strip
      work_params[:chapter_attributes][:title] = @doc.css(".chaptertitle").inner_text.gsub(/ by .*$/, '').strip
      
      # harvest data
      info = @doc.css(".infobox .content").inner_html

      if info.match(/Summary:.*?>(.*?)<br>/m)
        work_params[:summary] = clean_storytext($1)
      end      

      infotext = @doc.css(".infobox .content").inner_text      

      # Turn categories, genres, warnings into freeform tags
      tags = []
      if infotext.match(/Categories: (.*) Characters:/)
        tags += $1.split(',').map {|c| c.strip}.uniq unless $1 == "None"
      end
      if infotext.match(/Genres: (.*)Warnings/)
        tags += $1.split(',').map {|c| c.strip}.uniq unless $1 == "None"
      end
      if infotext.match(/Warnings: (.*)Challenges/)
        tags += $1.split(',').map {|c| c.strip}.uniq unless $1 == "None"
      end
      work_params[:freeform_string] = clean_tags(tags.join(ArchiveConfig.DELIMITER_FOR_OUTPUT))

      # use last updated date as revised_at date
      if site == "lotrfanfiction" && infotext.match(/Updated: (\d\d)\/(\d\d)\/(\d\d)/)
        # need yy/mm/dd to convert
        work_params[:revised_at] = convert_revised_at("#{$3}/#{$2}/#{$1}") 
      elsif site == "twilightarchives" && infotext.match(/Updated: (.*)$/)
        work_params[:revised_at] = convert_revised_at($1)
      end
      

      # get characters
      if infotext.match(/Characters: (.*)Genres:/)
        work_params[:character_string] = $1.split(',').map {|c| c.strip}.uniq.join(',') unless $1 == "None"
      end

      # save the readcount
      readcount = 0
      if infotext.match(/Read: (\d+)/)
        readcount = $1
      end
      work_params[:notes] = (readcount == 0 ? "" : "<p>This work was imported from another site, where it had been read #{readcount} times.</p>")

      # story notes, chapter notes, end notes
      @doc.css(".notes").each do |note|
        if note.inner_html.match(/Story Notes/)
          work_params[:notes] += note.css('.noteinfo').inner_html
        elsif note.inner_html.match(/(Chapter|Author\'s) Notes/)
          work_params[:chapter_attributes][:notes] = note.css('.noteinfo').inner_html
        elsif note.inner_html.match(/End Notes/)
          work_params[:chapter_attributes][:endnotes] = note.css('.noteinfo').inner_html
        end
      end
      
      if infotext.match(/Completed: No/)
        work_params[:complete] = false
      else
        work_params[:complete] = true
      end

      return work_params
    end
    

    # Move and/or copy any meta attributes that need to be on the chapter rather
    # than on the work itself
    def shift_chapter_attributes(work_params)
      CHAPTER_ATTRIBUTES_ONLY.each_pair do |work_attrib, chapter_attrib|
        if work_params[work_attrib] && !work_params[:chapter_attributes][chapter_attrib]
          work_params[:chapter_attributes][chapter_attrib] = work_params[work_attrib]
          work_params.delete(work_attrib)
        end
      end

      # copy any attributes from work to chapter as necessary
      CHAPTER_ATTRIBUTES_ALSO.each_pair do |work_attrib, chapter_attrib|
        if work_params[work_attrib] && !work_params[:chapter_attributes][chapter_attrib]
          work_params[:chapter_attributes][chapter_attrib] = work_params[work_attrib]
        end
      end

      work_params
    end


    # Find any cases of the given pieces of meta in the given text
    # and return a hash of meta values
    def scan_text_for_meta(text)
      # break up the text with some extra newlines to make matching more likely
      # and strip out some tags
      text = text.gsub(/<br/, "\n<br")
      text.gsub!(/<p/, "\n<p")
      text.gsub!(/<\/?span(.*?)?>/, '')
      text.gsub!(/<\/?div(.*?)?>/, '')

      meta = {}
      metapatterns = META_PATTERNS
      is_tag = {}
      ["fandom_string", "relationship_string", "freeform_string", "rating_string"].each do |c|
        is_tag[c.to_sym] = true
      end
      metapatterns.each do |metaname, pattern|
        # what this does is look for pattern: (whatever)
        # and then sets meta[:metaname] = whatever
        # eg, if it finds Fandom: Stargate SG-1 it will set meta[:fandom] = Stargate SG-1
        # then it runs it through convert_<metaname> for cleanup if such a function is defined (eg convert_rating_string)
        metapattern = Regexp.new("(#{pattern})\s*:\s*(.*)", Regexp::IGNORECASE)
        metapattern_plural = Regexp.new("(#{pattern.pluralize})\s*:\s*(.*)", Regexp::IGNORECASE)
        if text.match(metapattern) || text.match(metapattern_plural)
          value = $2
          if value.match(metapattern) || value.match(metapattern_plural)
            value = $2
          end
          value = clean_tags(value) if is_tag[metaname]
          value = clean_close_html_tags(value)
          value.strip! # lose leading/trailing whitespace
          begin
            value = eval("convert_#{metaname.to_s.downcase}(value)")
          rescue NameError
          end
          meta[metaname] = value
        end
      end
      return meta
    end

    def download_with_timeout(location, limit = 10)
      story = ""
      Timeout::timeout(STORY_DOWNLOAD_TIMEOUT) {
        begin
          # we do a little cleanup here in case the user hasn't included the 'http://' 
          # or if they've used capital letters or an underscore in the hostname
          uri = URI.parse(location)
          uri = URI.parse('http://' + location) if uri.class.name == "URI::Generic"
          uri.host.downcase!
          uri.host.gsub!(/_/, '-')
          response = Net::HTTP.get_response(uri)
          case response
          when Net::HTTPSuccess
            story = response.body
          when Net::HTTPRedirection
            if limit > 0
              story = download_with_timeout(response['location'], limit - 1) 
            else
              nil
            end
          else
           nil
          end
        rescue Errno::ECONNREFUSED
          nil
        rescue SocketError
          nil
        rescue EOFError
          nil
        end
      }
      if story.blank?
        raise Error, "We couldn't download anything from #{location}. Please make sure that the URL is correct and complete, and try again."
      end
      story
    end

    def get_last_modified(location)
      Timeout::timeout(STORY_DOWNLOAD_TIMEOUT) {
        resp = open(location)
        resp.last_modified
      }
    end

    def get_source_if_known(known_sources, location)
      known_sources.each do |source|
        pattern = Regexp.new(eval("SOURCE_#{source.upcase}"), Regexp::IGNORECASE)
        if location.match(pattern)
          return source
        end
      end
      nil
    end

    def clean_close_html_tags(value)
      # if there are any closing html tags at the start of the value let's ditch them
      value.gsub(/^(\s*<\/[^>]+>)+/, '')
    end

    # We clean the text as if it had been submitted as the content of a chapter
    def clean_storytext(storytext)
      storytext = storytext.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "") unless storytext.encoding.name == "UTF-8"
      return sanitize_value("content", storytext)
    end

    # works conservatively -- doesn't split on
    # spaces and truncates instead.
    def clean_tags(tags)
      tags = Sanitize.clean(tags) # no html allowed in tags
      if tags.match(/,/)
        tagslist = tags.split(/,/)
      else
        tagslist = [tags]
      end
      newlist = []
      tagslist.each do |tag|
        tag.gsub!(/[\*\<\>]/, '')
        tag = truncate_on_word_boundary(tag, ArchiveConfig.TAG_MAX)
        newlist << tag unless tag.blank?
      end
      return newlist.join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
    end

    def truncate_on_word_boundary(text, max_length)
      return if text.blank?
      words = text.split()
      truncated = words.first
      if words.length > 1
        words[1..words.length].each do |word|
          truncated += " " + word if truncated.length + word.length + 1 <= max_length
        end
      end
      truncated[0..max_length-1]
    end

    # convert space-separated tags to comma-separated
    def clean_and_split_tags(tags)
      if !tags.match(/,/) && tags.match(/\s/)
        tags = tags.split(/\s+/).join(',')
      end
      return clean_tags(tags)
    end

    # Convert the common ratings into whatever ratings we're
    # using on this archive.
    def convert_rating(rating)
      rating = rating.downcase
      if rating.match(/^(nc-?1[78]|x|ma|explicit)/)
        ArchiveConfig.RATING_EXPLICIT_TAG_NAME
      elsif rating.match(/^(r|m|mature)/)
        ArchiveConfig.RATING_MATURE_TAG_NAME
      elsif rating.match(/^(pg-?1[35]|t|teen)/)
        ArchiveConfig.RATING_TEEN_TAG_NAME
      elsif rating.match(/^(pg|g|k+|k|general audiences)/)
        ArchiveConfig.RATING_GENERAL_TAG_NAME
      else
        ArchiveConfig.RATING_DEFAULT_TAG_NAME
      end
    end

    def convert_rating_string(rating)
      return convert_rating(rating)
    end

    def convert_revised_at(date_string)
      begin
        date = nil
        if date_string.match(/^(\d+)$/)
          # probably seconds since the epoch
          date = Time.at($1.to_i)
        end
        date ||= Date.parse(date_string)
        return '' if date > Date.today
        return date
      rescue ArgumentError, TypeError
        return ''
      end
    end
    
    # tries to find appropriate existing collections and converts them to comma-separated collection names only
    def get_collection_names(collection_string)
      cnames = ""
      collection_string.split(',').map {|cn| cn.squish}.each do |collection_name|
        collection = Collection.find_by_name(collection_name) || Collection.find_by_title(collection_name)
        if collection 
          cnames += ", " unless cnames.blank?
          cnames += collection.name
        end
      end
      cnames
    end

end
