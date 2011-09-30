# encoding: UTF-8

namespace :massimport do

  ##### HELPERS

  # send invitations to external authors for a given set of works
  def send_external_invites(works, archivist)
    # TESTING ohhh this is not ok, must fix before actually running
    @external_authors = works.collect(&:external_authors).flatten.uniq
    if !@external_authors.empty?
      @external_authors.each do |external_author|
        external_author.find_or_invite(archivist)
      end
    end
  end  

  # This loads up the story metadata from an ARCHIVE_DB.pl file and puts it into work params
  #
  # ATTRIBUTE NAME MAPPING:
  # a hash of attribute names in the format :original_attribute_name => :ao3_attribute_name 
  # this will map various attribute names to their AO3 equivalent, eg
  # {:storysummary => :summary, :fandom => :fandom_string} 
  # 
  # NOTE: use all lowercase on both sides, do NOT remap location!
  #
  # VALUE MAPPING:
  # a hash of :ao3_attribute_name => :method_name
  # this will evaluate the given story parser method on the given attribute's existing value (after doing any attribute name mapping)
  # in order to produce a value appropriate for the AO3
  def load_automated_archive_db(filename, attrs_to_keep = [], attribute_name_mapping = {}, value_mapping = {})
    db = Array.new
    work_params = HashWithIndifferentAccess.new
    @storyparser = StoryParser.new
    
    File.read(filename, :encoding => 'UTF-8').split(/\n/).each do |line|
      next unless line.present?
      case
      when line.match(/(\d+) =\> \{/)
        work_params = HashWithIndifferentAccess.new
      when line.match(/^\}\,/)
        db << work_params
      when line.match(/(\w+)\s*=>\s*'(.*)',\s*$/)
        next unless attrs_to_keep.include?($1.downcase)
        attribute_name = attribute_name_mapping[$1.downcase] || $1.downcase
        value = value_mapping[attribute_name] && $2 ? @storyparser.send(value_mapping[attribute_name], $2) : $2
        work_params[attribute_name] = value
      end
    end    
    db
  end

  # This expects each story file to be located in base_dir/location.filetype
  # so you just take the archive/ directory contents and pop them into base_dir
  # Expects @db to be set up already
  def load_automated_archive_stories(db, base_dir, parse_method)
    db.each do |work_params|
      storyfile = base_dir + "archive/" + work_params[:location] + '.' + work_params[:filetype]
      story = File.read(storyfile) rescue ""
      work_params[:chapter_attributes] = {:content => self.send(parse_method, story)}
    end
    db
  end



  ##### ACTUAL MASS IMPORT METHODS



  desc "Import works from intimations.org"
  # one example site
  task(:astolat => :environment) do
    BASEURL = "http://www.intimations.org/fanfic/"
    pseuds = Pseud.parse_bylines("astolat")[:pseuds]
    existing_work_titles = Work.written_by_id(pseuds.map{ |p| p.id }).map{ |w| w.title.downcase }

    puts "Importing Astolat's work from intimations.org..."
    indexparser = StoryParser.new
    index = indexparser.download_text(BASEURL + "index.cgi?sortby=allbydate")
    index = Nokogiri::HTML.parse(index)
    index.css("td.storyentry").each do |storyentry|
      storyentry.inner_html.match /\s*<a class="storytitle" href="(.*?)"><b>(.*?)<\/b>.*?<br>\s*(.*?)<br>\s*(.*?)<br>\s*(.*)/
      url, title, fandom, date, summary = $1, $2, $3, $4, $5
      
      if url.nil?
        puts "Couldn't get URL from entry, skipping:"
        p storyentry.inner_html
        next
      end

      title = title.strip.gsub("<br>", " ").gsub("&amp;", "&")
      
      if existing_work_titles.include? title.downcase
        puts "'#{title}' seems to exist already, skipping."
        next
      end

      puts "Downloading '#{title}' from #{BASEURL + url}..."

      storyparser = StoryParser.new
      options = {
        :do_not_set_current_author => true,
        :pseuds => pseuds,
        :fandom => fandom,
        :post_without_preview => true,
        :encoding => "iso-8859-1"
      }
        
      work = storyparser.download_and_parse_story(BASEURL + url, options)
      work.title = title
      work.revised_at = storyparser.convert_revised_at(date)
      work.summary = storyparser.clean_storytext(summary)
      work.save
      
    end
  end


  #### YULETIDE

  desc "Import the Yuletide archive OMG"
  task(:yuletide => :environment) do
    @archivist = User.find_by_login("YuletideArchivist")
    unless @archivist && @archivist.is_archivist?
      puts "Please create the YuletideArchivist account and get it set up as an archivist first!"
      exit
    end
    
    # Copy the archive/ folder and the ARCHIVE_DB.pl file in here
    BASE_DIR = "/home/shalott/yuletide/"
    
    # specify which attributes to keep from the db - will have to delete any that are not valid work attributes
    attrs_to_keep = %w(author date email fandom rating summary title recipient location filetype writtenfor)
    
    # change some attribute names
    attr_mapping = HashWithIndifferentAccess.new({
      :fandom => :fandom_string,
      :rating => :rating_string,
      :writtenfor => :collection_names,
      :date => :revised_at
    })
    
    # run some attributes through storyparser cleanup
    val_mapping = HashWithIndifferentAccess.new({
      :rating_string => :convert_rating,
      :collection_names => :get_collection_names,
      :revised_at => :convert_revised_at
    })
    
    # load the db
    @db = load_automated_archive_db(BASE_DIR + "yuletide_abbrev_db.pl", attrs_to_keep, attr_mapping, val_mapping)
    
    # load the actual story files into the db
    @db = load_automated_archive_stories(@db, BASE_DIR, :parse_content_from_yuletide_file)

    # get set up to create the works
    @storyparser ||= StoryParser.new
    options = {
      :do_not_set_current_author => true,
      :archivist => @archivist,
      :post_without_preview => true,
      :encoding => "iso-8859-1"
    }

    works = []
    errors = []
    
    @db.each do |work_params|
      begin
        # TESTING
        work_params[:email] = 'shalott+yuletidetesting@gmail.com'
      
        # get the author
        external_author_name = @storyparser.parse_author_common(work_params.delete(:email), work_params.delete(:author))
      
        # set some tags
        work_params[:freeform_string] = @storyparser.clean_tags("yuletide, recipient:#{work_params.delete(:recipient)}")
      
        # clean out any attributes we want to use for processing but that aren't part of AO3 work attributes
        location = work_params.delete(:location)
        filetype = work_params.delete(:filetype)
      
        # actually create the work and set it up
        work = @storyparser.set_work_attributes(Work.new(work_params), "http://yuletidetreasure.org/archive/#{location}.#{filetype}", 
                                        options.merge(:external_author_name => external_author_name))
    
        if work && work.valid?
          puts "Yay work: #{work.title} by #{work.external_author_names.map {|ean| ean.to_s}.join}"
          unless @first_seen
            puts "WHOLE THING: #{work.to_yaml}"
            @first_seen = true
          end
          # work.chapters.each {|chap| chap.save}
          # add comments
          # get the comments
          get_comments_from_yuletide(BASE_DIR, location).each do |comment|
            comment_object = Comment.new(:commentable_type => 'Work', :commentable_id => work, :name => comment[:name], :email => "yuletidecommenter@gmail.com", :content => comment[:content])
            if comment_object.valid?
              puts "Yay comment by #{comment.name}"
            end
          end
        
          works << work
        else
          errors << "Problem with #{work_params[:title]}: " + work.errors.full_messages.join(', ')
        end
      rescue Exception => e
        errors << "We ran into a problem on #{work_params[:title]}: " + e.message
      end
    end

    puts errors.join("\n")
    # send_external_invites(works, @archivist)
  end

  ### YULETIDE-SPECIFIC HELPERS

  def get_comments_from_yuletide(base_dir, location)
    commentfile = File.read(base_dir + "archive/" + location + '_cmt.html') rescue ""
    commentdoc = Nokogiri::HTML.parse(commentfile) rescue ""
    comments = []
    commentdoc.css('.form table.form tr').each do |row|
      name = row.css('td')[0].inner_text.match(/From: (.*)\n?Date/) ? $1 : "Unknown Commenter"
      text = row.css('td')[1].inner_text
      next unless text
      comments << {:name => name, :content => text}
    end
    comments
  end

  # This gets the content out of a yuletide story file
  def parse_content_from_yuletide_file(story)
    @doc = Nokogiri::HTML.parse(story) rescue ""
    content_table = (@doc/"table[@class='form']/tr/td[2]")
    content = ""
    unless content_table
      content = (@doc/"body").inner_html
    else
      centers = content_table.css("center")
      centers[0].remove
      # trying to remove comment links at the bottom
      if !centers[-1].nil? && centers[-1].to_html.match(/<!-- COMMENTLINK START -->/)
        centers[-1].remove
      end
      content = content_table.inner_html
    end
    
    @storyparser ||= StoryParser.new
    content = @storyparser.clean_storytext(content)
    content.gsub!(/<a href="\//, '<a href="http://yuletidetreasure.org/')
    content
  end



end

