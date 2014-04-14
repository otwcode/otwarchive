# encoding: UTF-8

namespace :massimport do

  LOG_FILE = File.open("#{Rails.root.to_s}/log/852.log", "w")

  ##### GENERAL HELPERS
  
  def message(message)
    puts "#{message}"
    LOG_FILE.puts(message)
  end
  
  def ask(message)
    print "#{message} "
    STDIN.gets.chomp.strip
  end
  
  # get the directory where the files are sitting
  def get_base_dir(base_dir_default = "/var/www/otwarchive/current/tmp/archive_import/")
    base_dir = ask("Please enter the base directory where the archive files are located: (#{base_dir_default}) >")
    base_dir = base_dir_default if base_dir.blank?
    base_dir += '/' unless base_dir.match(/\/$/)
    until base_dir.present? && Dir.exists?(base_dir)
      message( "Couldn't find #{base_dir}!")
      base_dir = ask("Please enter the base directory where the archive files are located: ")
      base_dir += '/' unless base_dir.match(/\/$/)
    end
    message("\nUsing " + base_dir)
    base_dir
  end

  # send invitations to external authors for a given set of works
  def send_external_invites(work_ids, archivist)
    @users = User.select("DISTINCT users.*").joins(:creatorships).where("creation_id IN (?) AND creation_type = 'Work'", work_ids)
    @users.each do |user|
      UserMailer.deliver_claim_notification(user.id, work_ids, true)
    end
    @external_authors = ExternalAuthor.select("DISTINCT external_authors.*").joins(:external_creatorships).where("creation_id IN (?) AND creation_type = 'Work'", work_ids)
    @external_authors.each do |external_author|
      external_author.find_or_invite(archivist)
    end
  end


  
  # add to a collection and approve the item
  def collection_approve(work, collection)
    work.collection_items.each do |ci|
      next unless ci.collection == collection
      ci.update_attribute(:collection_approval_status, CollectionItem::APPROVED)
      ci.update_attribute(:user_approval_status, CollectionItem::APPROVED)
      ci.save
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
  def load_automated_archive_db(filename, attrs_to_keep = [], attribute_name_mapping = {}, value_mapping = {}, values_to_set = {})
    db = Array.new
    work_params = HashWithIndifferentAccess.new
    @storyparser = StoryParser.new

    unless File.exists?(filename) && File.readable?(filename)
      message("Cannot read #{filename}")
      exit
    end

    File.read(filename, :encoding => 'ISO-8859-1').split(/\n/).each do |line|
      next if line.blank? || line.match(/^#/)
      case
      when line.match(/^\s*(\d+) =\> \{/)
        # start of a record
        work_params = HashWithIndifferentAccess.new
      when line.match(/^\s*\}\,/)
        # finish up the record
        # add in any values we want to tack on (eg a common fandom)
        values_to_set.each_pair do |key, val|
          work_params[key] = val
        end
        db << work_params
      when line.match(/^\s*(\w+)\s*=>\s*'(.*)',\s*$/)
        attr_name = $1.downcase
        value_in_file = $2
        # replace escaped apostrophes
        value_in_file.gsub!(/\\\'/, "'")
        next unless attrs_to_keep.include?(attr_name)
        attribute_name = attribute_name_mapping[attr_name] || attr_name
        value = value_mapping[attribute_name] && value_in_file ? @storyparser.send(value_mapping[attribute_name], value_in_file) : value_in_file
        work_params[attribute_name] = value
      end
    end
    db
  end

  def load_automated_archive_comments_for_work(work, base_dir, location, comment_parse_method)
    comment_count = 0
    self.send(comment_parse_method, base_dir, location).each do |comment|
      comment_object = Comment.new(:commentable_type => 'Chapter', :commentable_id => work.chapters.last.id, :name => comment[:name], :email => comment[:email], :content => comment[:content])
      if comment_object.save
        comment_count += 1
      else
        puts "We ran into errors loading a comment: " + comment_object.errors.full_messages.join(', ')
      end
    end
    puts "Loaded #{comment_count} comments"
  end

  # This processes a bunch of AA stories and db entries
  # Arguments: 
  ## archivist: the User object who is the archivist
  ## db: a hash created by load_automated_archive_db
  ## options: 
  ### :base_dir -- the directory with the actual files from the rescued archive in it
  ### :base_url -- the original URL for the rescued archive eg "http://smallville.slashdom.net"
  ### :story_parse_method -- the method to parse the individual story files
  ### :storyparser_options -- arguments to pass to StoryParser call for each story
  ### :encoding -- if you don't want it to default to iso-8859-1
  ### :load_comments -- if true attempt to load comments
  ### :comment_parse_method -- the method to use to parse
  ### 
  def load_automated_archive_works(archivist, db, options = {})
    # get set up to create the works
    @storyparser ||= StoryParser.new
    storyparser_options = {
      :do_not_set_current_author => true,
      :archivist => archivist,
      :importing_for_others => true,
      :post_without_preview => true,
      :encoding => (options[:encoding] || "iso-8859-1")
    }.reverse_merge((options[:storyparser_options] || {}))
  
    message("Running load_automated_archive_works")
    work_ids = []
    errors = []
    db.each do |work_params|
      begin
        # clean out any attributes we want to use for processing but that aren't part of AO3 work attributes
        location = work_params.delete(:location)
        filetype = work_params.delete(:filetype)
        # storyfile = options[:base_dir] + "archive/#{location}.#{filetype}"
        storyfile = options[:base_dir] + "/#{location}.#{filetype}"
  
        message("\nProcessing " + storyfile)
        url = options[:base_url] + "/#{location}.#{filetype}"
  
        # check to see if it's already imported
        work = Work.find_by_imported_from_url(url)
        if work
          collection_names = work_params[:collection_names].split(/,\s?/)
          Collection.where(:name => collection_names).each do |c|
            work.collections << c unless work.collections.include?(c)
            message("Added existing work #{work.title} to #{c.title}")
          end
          work_ids << work.id
          next # don't recreate the work
        end
  
        # read the story file and update the work params accordingly
        story = File.read(storyfile, :encoding => 'ISO-8859-1') rescue ""
        work_params = self.send(options[:story_parse_method], work_params, story)
  
        # replace email when testing
        #work_params[:email] = options[:author_email] if options[:author_email]
  
        # get the author
        author = work_params.delete(:author)
        emails = work_params.delete(:email) || ""
        external_author_names = emails.split(',').map {|email| @storyparser.parse_author_common(email, author)}
  
        # create the work and set it up
        work = @storyparser.set_work_attributes(Work.new(work_params), url,
                                storyparser_options.merge(:imported_from_url => url, :external_author_names => external_author_names))
  
        # check for errors
        if work && work.valid?
          message("Loaded work: #{work.external_creatorships.each {|ec| ec.to_s}.join}")
          work.chapters.each do |chap|
            chap.published_at = work.revised_at
            chap.save
          end
          work.save
          work.set_word_count
          work.save
  
          # get the comments
          if options[:load_comments] && options[:comment_parse_method]
            load_automated_archive_comments_for_work(work, options[:base_dir], location, options[:comment_parse_method])
          end
  
          work_ids << work.id
        else
          errors << "\nProblem with #{work_params[:title]}: \n" + work.errors.full_messages.join(', ') + "\n" + work_params.to_yaml
  
        end
      rescue Exception => e
        errors << "We ran into a problem on #{work_params[:title]}: " + e.message # + e.backtrace.join("\n")
      end
    end
  
    message(errors.join("\n"))
    return work_ids
  end


  # Run the whole rescue
  # options:
  ## :author_email -- if set use this as the author for all the imported stories, for testing only
  ## :archivist -- login of the archivist user
  ## :
  def automated_archive_rescue(options = {})
    options.reverse_merge!({
      :send_invites => true,
      :archivist_login => nil,
      :archive_file => "ARCHIVE_DB.pl",
      :attrs_to_keep => [],
      :attr_mapping => {},
      :val_mapping => {},
      :values_to_set => {},
      :base_url => "",
      :story_parse_method => nil,
      :comment_parse_method => nil,
      :load_comments => false,
    })
  
    base_dir = get_base_dir
  
    archivist_login = options[:archivist_login] || ask("Archivist login?")
    archivist = User.find_by_login(archivist_login)
    unless archivist && archivist.is_archivist?
      message("Please create the #{options[:archivist]} account as an archivist first!")
      exit
    end
  
    # load db
    db = load_automated_archive_db(base_dir + options[:archive_file], options[:attrs_to_keep], options[:attr_mapping], options[:val_mapping], options[:values_to_set])
  
    # create works and comments
    work_ids = load_automated_archive_works(archivist, db, :base_url => options[:base_url], :base_dir => base_dir,
                  :story_parse_method => options[:story_parse_method],
                  :load_comments => options[:load_comments], :comment_parse_method => options[:comment_parse_method],
                  :author_email => options[:author_email])
  
    # send invites and notifications if the command line option is set
    if options[:send_invites] == "true"
      message("Sending invites and notifications")
  
      send_external_invites(work_ids, archivist)
    end
  end


  ##### HELPER TASKS
  desc "Wipe collection and reload"
  task(:wipe_and_reload, [:send_invites] => :environment) do |t, args|
    args.with_defaults(:send_invites => false)
  
    Rake::Task['massimport:clear_collection_testing_only'].invoke
    Rake::Task["massimport:prospect"].invoke(args.send_invites)
  end
  
  desc "Clear collection TESTING ONLY"
  task(:clear_collection_testing_only => :environment) do
    collection_name = ask("Name of the collection name to wipe? (ALL WORKS IN THIS COLLECTION WILL BE DELETED!!!!) ")
    c = Collection.find_by_name(collection_name)
    unless c
      puts "No collection #{collection_name} found!"
      exit
    end
  
    work_ids = c.works.value_of :id
    external_authors = ExternalCreatorship.where(:creation_id => work_ids, :creation_type => 'Work').collect(&:external_author_name).compact.collect(&:external_author).compact.uniq
  
    # remove the works
    Work.where(:id => work_ids).destroy_all
  
    # get rid of external authors
    external_authors.select {|ea| ea.works.count == 0}.each do |ea|
      puts "Destroying external #{ea.email}"
      ea.destroy
    end
  
  end

  desc "Create archivist and collection if they don't already exist"
  task(:create_archivist_and_collection => :environment) do
    @archivist_login ||= ask("Archivist login? ")
    # make the archivist user if it doesn't exist already
    u = User.find_or_initialize_by_login(@archivist_login)
    if u.new_record?
      archivist_password = ask("Archivist temp password? ")
      archivist_email = ask("Archivist email? ")
      u.password = archivist_password 
      u.email = archivist_email
      u.age_over_13 = "1"
      u.terms_of_service = "1"
      u.password_confirmation = archivist_password
      u.save
    end
    unless u.is_archivist?
      u.roles << Role.find_by_name("archivist")
      u.save
    end
    # make the collection if it doesn't exist already
    @collection_name ||= ask("Collection name (no spaces or extended characters)? ")
    c = Collection.find_or_initialize_by_name(@collection_name)
    if c.new_record?
      @collection_title ||= ask("Collection title? ")
      c.title = @collection_title
    else
      collection_title = c.title
    end
    # add the user as an owner if not already one
    unless c.owners.include?(u.default_pseud)
      p = c.collection_participants.where(:pseud_id => u.default_pseud.id).first || c.collection_participants.build(:pseud => u.default_pseud)
      p.participant_role = "Owner"
      c.save
      p.save
    end
    c.save
    puts "Archivist #{u.login} set up as owner of collection #{c.title} (#{c.name})."
  end

  ##### ACTUAL MASS IMPORT METHODS

  #### 852 Prospect

  desc "Import the 852 Prospect Sentinel archive"
  task(:prospect, [:send_invites] => :environment) do |t, args|
    args.with_defaults(:send_invites => false)
  
  
    message("Send invites: #{args.send_invites}")
  
    @archivist_login = nil # insert user name here to skip prompt
    @collection_name = nil # will be eg: "852_prospect_archive"
    @collection_title = nil # eg: "852 Prospect Archive"
    @send_invites = args.send_invites
    Rake::Task['massimport:create_archivist_and_collection'].invoke
  
    base_url = "http://www.852prospect.org/archive/archive"
    archive_file = ask("Name of archive file (eg: ARCHIVE_DB.pl)? ") # "ARCHIVE_MINI.pl"
    author_email = nil
  
    message("Archive file: #{archive_file}")
  
    # specify which attributes to keep from the db - will have to delete any that are not valid work attributes
    attrs_to_keep = %w(author category date email rating pairing summary title location filetype warnings)
    #removed: printabletime sequelname size
  
    # change some attribute names
    # author name and email are already in :author, :email (required for parsing the author)
    attr_mapping = HashWithIndifferentAccess.new({
      :rating => :rating_string,
      :date => :revised_at,
      :pairing => :relationship_string,
      :category => :freeform_string,
      :warnings => :warning_strings
    })
  
    # run some attributes through storyparser cleanup routines
    val_mapping = HashWithIndifferentAccess.new({
      :rating_string => :convert_rating,
      :revised_at => :convert_revised_at,
      :summary => :clean_storytext
    })
  
    values_to_set = HashWithIndifferentAccess.new({
      :collection_names => @collection_name,
      :fandom_string => "The Sentinel"
    })
  
    automated_archive_rescue(
      :send_invites => args.send_invites,
      :archivist_login => @archivist_login,
      :base_url => base_url,
      :author_email => author_email,
      :attrs_to_keep => attrs_to_keep,
      :attr_mapping => attr_mapping, :val_mapping => val_mapping,
      :values_to_set => values_to_set,
      :archive_file => archive_file,
      :story_parse_method => :parse_content_from_852_file,
      :load_comments => false)
  
  end
  
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

  # This is the model for importing any Automated Archive
  # To create another:
  # - change base_url as appropriate
  # - create the appropriate archivist account and redefine @archivist
  # - redefine attr_mapping and val_mapping. 
  # - MAKE SURE that the author name is in :author and the author email is in :email
  # - define a method to extract the story content out of the individual story files (see parse_content_from_yuletide_file)
  # - if you want to load comments define a method for that (see get_comments_from_yuletide)
  desc "Import the Yuletide archive OMG"
  task(:yuletide => :environment) do
    @archivist_login = "YuletideArchivist"

    # The base url for the original archive directory
    base_url = "http://yuletidetreasure.org/archive/"
    
    # The archive_db.pl file (you probably want to test with an abbreviated version first)
    archive_file = "yuletide_abbrev_db.pl" # 'ARCHIVE_DB.pl'

    # Use this for testing or you'll spam actual users
    author_email = "shalott+yuletidetesting@gmail.com"
    
    # the archivist account that will be the actual owner of the story files initially
    
    # specify which attributes to keep from the db - will have to delete any that are not valid work attributes
    attrs_to_keep = %w(author date email fandom rating summary title recipient location filetype writtenfor)
    
    # change some attribute names
    # IMPORTANT: author name and email are already in :author, :email (required for parsing the author)
    attr_mapping = HashWithIndifferentAccess.new({
      :fandom => :fandom_string,
      :rating => :rating_string,
      :writtenfor => :collection_names,
      :date => :revised_at,
      :recipient => :recipients
    })
    
    # run some attributes through storyparser cleanup routines
    val_mapping = HashWithIndifferentAccess.new({
      :rating_string => :convert_rating,
      :collection_names => :get_collection_names,
      :revised_at => :convert_revised_at,
      :summary => :clean_storytext
    })
    
    automated_archive_rescue(:archivist_login => @archivist_login, :base_url => base_url, :author_email => author_email, 
      :attrs_to_keep => attrs_to_keep, :attr_mapping => attr_mapping, :val_mapping => val_mapping,
      :archive_file => archive_file, :story_parse_method => :parse_content_from_yuletide_file, :comment_parse_method => :get_comments_from_yuletide, 
      :load_comments => true)
  end
  
  ### SSA
  desc "Import the Smallville Slash Archive"
  task(:ssa => :environment) do
    
    @archivist_login = "ssa_archivist"
    @collection_name = "smallville_slash_archive"    
    Rake::Task['massimport:create_archivist_and_collection'].invoke

    base_url = "http://smallville.slashdom.net/archive"
    archive_file = "ARCHIVE_DB.pl"
    author_email = nil # for testing use: "shalott+ssatesting@gmail.com"
    
    # specify which attributes to keep from the db - will have to delete any that are not valid work attributes
    attrs_to_keep = %w(author category date email rating pairing summary title location filetype)

    # change some attribute names
    # author name and email are already in :author, :email (required for parsing the author)
    attr_mapping = HashWithIndifferentAccess.new({
      :rating => :rating_string,
      :date => :revised_at,
      :pairing => :relationship_string,
      :category => :freeform_string
    })

    # run some attributes through storyparser cleanup routines
    val_mapping = HashWithIndifferentAccess.new({
      :rating_string => :convert_rating,
      :revised_at => :convert_revised_at,
      :summary => :clean_storytext
    })
    
    values_to_set = HashWithIndifferentAccess.new({
      :collection_names => @collection_name,
      :fandom_string => "Smallville"
    });
    
    automated_archive_rescue(:archivist_login => @archivist_login, :base_url => base_url, :author_email => author_email, 
      :attrs_to_keep => attrs_to_keep, :attr_mapping => attr_mapping, :val_mapping => val_mapping,
      :values_to_set => values_to_set,
      :archive_file => archive_file, :story_parse_method => :parse_content_from_ssa_file, :load_comments => false)
  end  
  
  desc "Import the Due South Archive"
  task(:dsa => :environment) do
    base_url = "http://www.squidge.org/dsa/archive"
    archive_file = "dsa_abbrev.pl"
    author_email = "shalott+dsatest@gmail.com"
    archivist = "dsa_archivist"
    c = Collection.find_by_name("dsa")
    unless c
      puts "Please create the dsa collection first!"
      exit
    end
    
    attrs_to_keep = %w(author category date email rating pairing summary title location filetype)

    # change some attribute names
    # author name and email are already in :author, :email (required for parsing the author)
    attr_mapping = HashWithIndifferentAccess.new({
      :rating => :rating_string,
      :date => :revised_at,
      :pairing => :relationship_string,
      :category => :freeform_string,
      :warnings => :warning_strings
    })

    # run some attributes through storyparser cleanup routines
    val_mapping = HashWithIndifferentAccess.new({
      :rating_string => :convert_rating,
      :revised_at => :convert_revised_at,
      :summary => :clean_storytext
    })
    
    values_to_set = HashWithIndifferentAccess.new({
      :collection_names => c.name,
      :fandom_string => "due South"
    });
    
    automated_archive_rescue(:archivist => archivist, :base_url => base_url, :author_email => author_email, 
      :attrs_to_keep => attrs_to_keep, :attr_mapping => attr_mapping, :val_mapping => val_mapping,
      :values_to_set => values_to_set,
      :archive_file => archive_file, :story_parse_method => :parse_content_from_dsa_file, :load_comments => false)
    
    
    
  end
  

  ### ARCHIVE-SPECIFIC HELPERS
  # 852 categories and story files
  def parse_content_from_852_file(work_params, story)
    # notes embedded in the file
    if story.match(/author's notes: (.*?)$/i)
      work_params[:notes] = $1
      story.gsub!(/author's notes: (.*)$/i, '')
    end

    # strip old archive links from bottom
    story.gsub!(/<hr>\s*<center>.*?<\/center>\s*<\/body>\s*<\/html>\s*$/im, '')
  
    # use first author as the story author if there are several
    if work_params[:author].include? ","
      work_params[:author] = work_params.delete(:author).split(/,\s*/)[0] + " and others"
    end
  
    category_string = "" ; warning_strings = "" ;  freeform_string = ","; relationship_string = ""
  
    # clean up existing freeforms
    categories = work_params.delete(:freeform_string) || ""
    categories.split(/,\s*/).each do |category|
      category.gsub!(/\A[^[:alnum:]]/, '')
      freeform_string += category + ","
    end
  
    # convert pairings into category and convert them to AO3 versions
    pairings = work_params[:relationship_string] || ""
    pairings.split(", ").each do |pairing|
      case pairing
      #when 'J/B'
      #  category_string += "F/F,"
        when 'J/B','J/S','B/S','J/B/S','J/B/f','J/m','B/m','S/m','J/B/m'
          category_string += "M/M,"
        when 'J/f', 'B/f', 'S/f', 'J/B/f'
          category_string += "M/F,"
        when 'J/B/S', 'J/B/m', 'J/B/f'
          category_string += "Multi,"
        when 'Pre-slash', 'pre-slash', 'Pre-Slash'
          freeform_string += "Pre-slash,"
        else
          freeform_string += pairing + ","
      end
  
      # change common pairings to their existing AO3 equivalent
      pairing.gsub!(/J\/B\/S/, "Simon Banks/Jim Ellison/Blair Sandburg")
      pairing.gsub!(/J\/S/, "Simon Banks/Jim Ellison")
      pairing.gsub!(/B\/S/, "Simon Banks/Blair Sandburg")
      pairing.gsub!(/J\/B/, "Jim Ellison/Blair Sandburg")
      # characters at start of string
      
      pairing.gsub!(/\AJ\//, "Jim Ellison/")
      pairing.gsub!(/\AB\//, "Blair Sandburg/")
      pairing.gsub!(/\AS\//, "Simon Banks/")
      #
      pairing.gsub!(/\/m\Z/, "/Undisclosed Male Character")
      pairing.gsub!(/\/f\Z/, "/Undisclosed Female Character")
      # then expand remaining atypical pairings to their full character names
      # using regex to match
      relationship_string += pairing + ","
    end
  
    # warnings includes both category and warning info; import the rest as freeforms
    warnings = work_params.delete(:warning_strings) || ""
    warnings.split(/,\s*/).each do |warning|
      case warning
        when "rape/nc"
          warning_strings += "Rape/Non-Con,"
        when "death story"
          warning_strings += "Major Character Death,"
        when "violence"
          warning_strings += "Graphic Depictions Of Violence,"
        when "m/m", "slash"
          category_string += "M/M,"
        when "m/f", "het"
          category_string += "M/F,"
        when "f/f"
          category_string += "F/F,"
        when "gen"
          category_string += "Gen,"
        else
          freeform_string += warning + ","
      end
    end
  
    work_params[:warning_strings] = warning_strings.chop unless warning_strings.blank?
    work_params[:category_string] = category_string.chop unless category_string.blank?
    work_params[:freeform_string] = freeform_string.chop unless freeform_string.blank?
    work_params[:relationship_string] = relationship_string.chop unless relationship_string.blank?
  
  
    # TODO: check how the story HTML is organised and process it to produce a decent result in AO3
    @doc = Nokogiri::HTML.parse(story) rescue ""

    # Use Nokogiri to grab emails and remove mailto links
    mailtos = @doc.xpath('//a[starts-with(@href,"mailto:")]')
    if mailtos.present?
      emails = mailtos.first.attributes['href'].value
      emails.gsub!("mailto:", "")

      # there are mailto in the format <a href="mailto:email_1, email_2"> so we just want the first one
      work_params[:email] = emails.split(',').first
      message("Email set to " + work_params[:email])

      # strip mailto: links to avoid spam
      mailtos.each do |m|
        m.replace(m.children.first)
      end
    end

    content = (@doc/"body").inner_html
    @storyparser ||= StoryParser.new
    content = @storyparser.clean_storytext(content)
    content.gsub!(/<a href="\//i, '<a href="http://852prospect.org/archive/')
    if content.length > ArchiveConfig.CONTENT_MAX
      # yikes
      content = content.chunk_string(400000)[0]
      content = "<p>ARCHIVE IMPORT NOTE: this story has been truncated due to length -- archivist or author must fix manually!</p><hr />" +
                content +
                "<hr /><p>ARCHIVE IMPORT NOTE: this story has been truncated due to length -- archivist or author must fix manually!</p>"
    end
  
    work_params[:chapter_attributes] = HashWithIndifferentAccess.new({:content => content})
  
    work_params
  end

  def parse_content_from_dsa_file(work_params, story)
    # warnings includes both category and warning info
    warning_strings = ""; category_string = "";
    warnings = work_params.delete(:warning_strings) || ""
    warnings.split(/,\s*/).each do |warning|
      case warning
      when "rape/nc"
        warning_strings += "Rape/Non-Con,"
      when "death story"
        warning_strings += "Major Character Death,"
      when "violence"
        warning_strings += "Graphic Depictions Of Violence,"
      when "m/m", "slash"
        category_string += "M/M,"
      when "m/f", "het"
        category_string += "M/F,"
      when "f/f"
        category_string += "F/F,"
      when "gen"
        category_string += "Gen,"
      end
    end
  
    work_params[:warning_strings] = warning_strings.chop unless warning_strings.blank?
    work_params[:category_string] = category_string.chop unless category_string.blank?
    
    @doc = Nokogiri::HTML.parse(story) rescue ""
    content_table = (@doc/"table[@class='content']/tr/td[2]")
    content = ""
    unless content_table
      content = (@doc/"body").inner_html
    else
      centers = content_table.css("center")
      unless centers[0].css("p")[0].nil?
        work_params[:notes] = centers[0].css("p")[0].inner_html
      end
      centers[0].remove
      # trying to remove comment links at the bottom
      if !centers[-1].nil? && centers[-1].to_html.match(/<!-- COMMENTLINK START -->/)
        centers[-1].remove
      end
      content = content_table.inner_html      
    end
    
    work_params[:chapter_attributes] = HashWithIndifferentAccess.new({:content => content})    
    work_params
  end
  
  # SSA has very basic story files
  def parse_content_from_ssa_file(work_params, story)
    # SSA has notes embedded in the file
    if story.match(/Notes: (.*)$/)
      work_params[:notes] = $1
      story.gsub!(/Notes: (.*)$/, '')
    end

    # strip old archive links from bottom
    story.gsub!(/<hr>\s*<center>.*?<\/center>\s*<\/body>\s*<\/html>\s*$/im, '')

    # strip mailto: links to avoid spam
    story.gsub!(/<a href=(?:'|")?mailto:.*?(?:'|")?>(.*?)<\/a>/i, '\1')
    
    # convert pairings into category
    category_string = ""
    pairings = work_params[:relationship_string] || ""
    pairings.split(", ").each do |pairing|
      case pairing
      when 'Chloe/Lana','Other f/f'
        category_string += "F/F,"
      when 'Clark/Jason', 'Clark/Lex', 'Clark/Whitney', 'Lex/Whitney','Lionel/Lex','Other m/m','Lex/other','Clark/other'
        category_string += "M/M,"
      when 'Other m/f'
        category_string += "M/F,"
      when 'Threesome'
        category_string += "Multi,"
      end
    end
    work_params[:category_string] = category_string.chop unless category_string.blank?
    
    @doc = Nokogiri::HTML.parse(story) rescue ""
    content = (@doc/"body").inner_html
    @storyparser ||= StoryParser.new
    content = @storyparser.clean_storytext(content)
    content.gsub!(/<a href="\//, '<a href="http://smallville.slashdom.net/')
    if content.length > ArchiveConfig.CONTENT_MAX
      # yikes
      content = content.chunk_string(400000)[0]
      content = "<p>ARCHIVE IMPORT NOTE: this story has been truncated due to length -- archivist or author must fix manually!</p><hr />" + 
                content + 
                "<hr /><p>ARCHIVE IMPORT NOTE: this story has been truncated due to length -- archivist or author must fix manually!</p>"
    end
    
    work_params[:chapter_attributes] = HashWithIndifferentAccess.new({:content => content})
      
    work_params
  end
  

  def get_comments_from_yuletide(base_dir, location)
    commentfile = File.read(base_dir + "archive/" + location + '_cmt.html', :encoding => 'ISO-8859-1') rescue ""
    commentdoc = Nokogiri::HTML.parse(commentfile) rescue ""
    comments = []
    commentdoc.css('.form table.form tr').each do |row|
      name = row.css('td')[0].inner_text.match(/From: (.*)\n?Date/) ? $1 : "Unknown Commenter"
      name.gsub(/ \(.*\@.*\)/, '') # strip emails
      text = row.css('td')[1].inner_text
      next unless text
      # encode to UTF-8
      comment = HashWithIndifferentAccess.new({
                  :email => "yuletidecommenter@gmail.com",
                  :name => name.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => ""), 
                  :content => text.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")})
      comments << comment
    end
    comments
  end

  # This gets the content out of a yuletide story file
  def parse_content_from_yuletide_file(work_params, story)
    @doc = Nokogiri::HTML.parse(story) rescue ""
    content_table = (@doc/"table[@class='form']/tr/td[2]")
    content = ""
    unless content_table
      content = (@doc/"body").inner_html
    else
      centers = content_table.css("center")
      unless centers[0].css("p")[0].nil?
        work_params[:notes] = centers[0].css("p")[0].inner_html
      end
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
    
    work_params[:chapter_attributes] = HashWithIndifferentAccess.new({:content => content})
  end



end

