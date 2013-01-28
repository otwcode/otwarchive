class MassImportTool
  require "mysql"

  def initialize()
    #Import Class Version Number
    @version = 1

    #not using for testing
    #import config filename
    #@config = "filename" #'

   #################################################
    #Database Settings
    ###############################################
    #Database Host Address (localhost)
    @database_host = "localhost"

    #Database Username (funnyuser)
    @database_username = "stephanies"

    #Database Password (password)
    @database_password = "Trustno1"

    #database name
    @database_name = "stephanies_development"

   #temporary table prefix to be added to table names during import
    @temptableprefix = "ODimport"
    #####################################################

    @archivist_login = nil
    @archivist_password = nil
    @archivist_email = nil



    #Match Existing Authors by Email-Address
    @match_existing_authors = true

    #Import Job Name
    @import_name = "New Import"
    @import_fandom = "Harry Potter"

    #Create record for imported archive (false if already exists)
    @create_import_archive_record = true

    #will error if not unique, just let it create it and assign it if you are unsure
    #Import Archive ID
    @import_archive_id = 100

    #Import reviews t/f
    @import_reviews = true

    #import categories as subcollections, if false, they will be converted to freeform tags
    @categories_as_subcollections = true


    #Message Values
    ####################################
    ##If true, send invites unconditionaly,
    # if false add them to the que to be sent when it gets to it, could be delayed.
    @bypass_invite_que = true

    #Send notification email with invitation to archive to imported users
    @notify_imported_users = true

    #Send message for each work imported? (or 1 message for all works)
    @send_individual_messages = false

    #Message to send existing authors
    @existing_notification_message = ""

    #message to be sent to users with no ao3 account
    @new_notification_message = ""

    #New Collection Values
    #####################################
    #ID Of the newly created collection, filled with value automatically if create collection is true
    @new_collection_id = 123456789

    #Create collection for imported works?
    @create_collection = true

    #Owner for created collection
    @new_collection_owner = "Stephanie"

    @new_collection_owner_pseud = "1010"

    @new_collection_title = "This is a title"


    @new_collection_name = "shortname"

    #New Collection Description
    @new_collection_description = "Something here"

    #=========================================================
    #Destination Options / Settings
    #=========================================================

    #If using ao3 cats, sort or skip
    @SortForAo3Categories = true

    #Import categories as categories or use ao3 cats
    @use_proper_categories = false

    #Destination otwarchive Ratings (1 being NR if NR Is conservative, 5 if not)
    #NR
    @target_rating_1 = 9

   #general audiences
    @target_rating_2 = 10

    #teen
    @target_rating_3 = 11

    #Mature
    @target_rating_4 = 12

    #Explicit
    @target_rating_5 = 13

    #========================
    #Source Variables
    #========================

    #Source Archive Type
    @source_archive_type = 4

    #If archivetype being imported is efiction 3 >  then specify what class holds warning information
    @source_warning_class_id = 1

    #Holds Value for source table prefix
    @source_table_prefix = "sl18_"

    ################# Self Defined based on above
    #Source Ratings Table
    @source_ratings_table = nil

    #Source Users Table
    @source_users_table = nil

    #Source Stories Table
    @source_stories_table = nil

    #Source Reviews Table
    @source_reviews_table = nil

    #Source Chapters Table
    @source_chapters_table = nil

    #Source Characters Table
    @source_characters_table = nil

    #Source Subcategories Table
    @source_subcatagories_table = nil

    #Source Categories Table
    @source_categories_table = nil

    #string holder
    @get_author_from_source_query = nil

    #############
    #debug stuff
    @debug_update_source_tags = true
    #Skip Rating Transformation (ie if import in progress or testing)
    @skip_rating_transform = false
  end


#below will be implemented when using config file, so its useless and hasnt been updated yet
=begin
  def ReadConfigValues()
    @ImportArchiveID = @config.GetValue("General", "ImportArchiveID", 0)
    @CollectionOwner = @config.GetValue("General", "CollectionOwner", "")
    @_tgtRating1 = @config.GetValue("General", "_tgtRating1", "")
    @_tgtRating2 = @config.GetValue("General", "_tgtRating2", "")
    @_tgtRating3 = @config.GetValue("General", "_tgtRating3", "")
    @_tgtRating4 = @config.GetValue("General", "_tgtRating4", "")
    @_tgtRating5 = @config.GetValue("General", "_tgtRating5", "")
    @useProperCategories = @config.GetValue("General", "useProperCategories", "")
    @existingAuthorMessage = @config.GetValue("General", "existingAuthorMessage", "")
    @newCollectionID = @config.GetValue("General", "newCollectionID", "")
    @NotificationMessage = @config.GetValue("General", "NotificationMessage", "")
    @CreateImportArchiveRecord = @config.GetValue("General", "CreateImportArchiveRecord", "")
    @bypassInviteQueForImported = @config.GetValue("General", "bypassInviteQueForImported", "")
    @NotifyImportedUsers = @config.GetValue("General", "NotifyImportedUsers", "")
    @srcArchiveType = @config.GetValue("General", "srcArchiveType", "")
    @srcWarningClassTypeID = @config.GetValue("General", "srcWarningClassTypeID", "")
    @source_table_prefix = @config.GetValue("General", "srcTablePrefix", "")
    @dbgSkipRatingTransform = @config.GetValue("General", "dbgSkipRatingTransform", "")
    @targetDBhost = "localhost"
  end
=end

=begin
# Convert Source DB Ratings to those of target archive in advance
  def transform_source_ratings()
    puts "transform source ratings"
    rating_field_name = ""
    case @source_archive_type
      #storyline

      when 4
        rating_field_name = "srating"
      #efiction 3
      when 3
        rating_field_name = "rid"
      #efiction 2
      when 2
    end

    self.update_record_target("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_1} where  #{rating_field_name} = 1;")
    self.update_record_target("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_2} where  #{rating_field_name} = 2;")
    self.update_record_target("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_3} where  #{rating_field_name} = 3;")
    self.update_record_target("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_4} where  #{rating_field_name} = 4;")
    self.update_record_target("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_5} where #{rating_field_name} = 5;")
  end

  #link up tags from source to target
  def fill_tag_list(tl)
    i = 0
    while i <= tl.length - 1
      temptag = tl[i]
      connection = Mysql.new('localhost','stephanies','Trustno1','stephanies_development')


      r = connection.query("Select id from tags where name = '#{temptag.tag}'; ")
      connection.close
      ##if not found add tag
      if r.num_rows == 0 then
        # '' self.update_record_target("Insert into tags (name, type) values ('#{temptag.tag}','#{temptag.tag_type}');")
        temp_new_tag = Tag.new()
        temp_new_tag.type = "#{temptag.tag_type}"
        temp_new_tag.name = "#{temptag.tag}"
        temp_new_tag.save

        temptag.new_id = temp_new_tag.id
      else
        r.each do |r|
          temptag.new_id = r[0]
        end
      end
      connection.close()
      #return importtag object with new id and its corresponding data ie old id and tag to array
      tl[i] = temptag
      i = i + 1
    end
    return tl
  end
=end

  #get all possible tags from source
  def get_tag_list(tl, at)
    taglist = tl


    case at
      #storyline
      when 4
        connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
        r = connection.query("Select caid, caname from #{@source_table_prefix}category; ")
        r.each do |r|
          nt = ImportTag.new()
          nt.tag_type = 1
          nt.old_id = r[0]
          nt.tag = r[1]
          taglist.push(nt)
        end


        rr = connection.query("Select subid, subname from #{@source_table_prefix}subcategory; ")
        unless rr.num_rows.nil? || rr.num_rows == 0
          rr.each do |rr|
            nt = ImportTag.new()
            nt.tag_type = 99
            nt.old_id = rr[0]
            nt.tag = rr[1]
            taglist.push(nt)
          end
        end
        connection.close
      #efiction 3
      when 3
        r = connection.query("Select class_id, class_type, class_name from #{@source_table_prefix}classes; ")
        r.each do |r|
          nt = ImportTag.new()
          if r[1] == @srcWarningClassTypeID
            nt.tag_type = 6
          else
            nt.tag_type = "freeform"
          end
          nt.old_id = r[0]
          nt.tag = r[2]
          taglist.push(nt)
        end

        rr = connection.query("Select catid, category from #{@source_table_prefix}categories; ")
        rr.each do |rr|
          nt = ImportTag.new()
          nt.tag_type = "category"
          nt.old_id = rr[0]
          nt.tag = rr[1]
          taglist.push(nt)

        end

        rrr = connection.query("Select charid, charname from #{@source_table_prefix}characters; ")
        rrr.each do |rrr|
          nt = ImportTag.new()
          nt.tag_type = "character"
          nt.old_id = rrr[0]
          nt.tag = rrr[1]
          taglist.push(nt)
        end
      when ArchiveType.efiction2
    end
    connection.close()
    return taglist
  end


=begin
  #update tags in source database to match destination values
  def update_source_tags(tl)
    case @source_archive_type
      #storyline
      when 4
        puts " Updating tags in source database for Archive Type 'StoryLine' "
        puts "updating source tags"
        i = 0
        while i <= tl.length - 1
          current_tag = tl[i]
          if current_tag.tag_type == 1
            self.update_record_source("update #{@source_stories_table} set scid = #{current_tag.new_id} where scid = #{current_tag.old_id}")
          end
          if current_tag.tag_type == 99
            self.update_record_source("update #{@source_stories_table} set ssubid = #{current_tag.new_id}  where ssubid = #{current_tag.old_id}")
          end
          i = i + 1
        end
        #efiction 3
      when 3
    end
  end
=end


  def create_child_collection(name,parent_id,description)

    collect = Collection.new()
      collect.name = @new_collection_name
      collect.description = @new_collection_description
      collect.title = new_collection_title

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
      external_author_names = options[:external_author_names] || parse_author(location)
      external_author_names = [external_author_names] if external_author_names.is_a?(ExternalAuthorName)
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

=begin
  def check_for_previous_import(location)
    work = Work.find_by_imported_from_url(location)
    if work
      raise Error, "A work has already been imported from #{location}."
    end
  end
=end
  ##################################################################################################
  # Main Worker Sub
  def import_data()
    #create collection & archivist
    self.create_archivist_and_collection

    puts " Setting Import Values "
    self.set_import_strings()

    if @skip_rating_transform == false
      puts " Tranforming source ratings "
      self.transform_source_ratings()
    else
      puts " Skipping source rating transformation per config "
    end

    #Update Tags and get Taglist
    puts " Updating Tags "
    tag_list = Array.new()
    tag_list = self.fill_tag_list(tag_list)

    connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
    r = connection.query("SELECT * FROM #{@source_stories_table} ;")
    connection.close()
    puts " Importing Stories "
    i = 0
    r.each do |row|
      puts " Importing Story #{i}"
      #create new ImportWork Object
      ns = ImportWork.new()
      #create new importuser object
      a = ImportUser.new()
      #Create Taglisit for this story
      my_tag_list = Array.new()
      begin
        case @source_archive_type
          #storyline
          when 4
            ns.source_archive_id = @import_archive_id
            ns.old_work_id = row[0]
            puts ns.old_work_id

            ns.title = row[1]
            #debug info
            puts ns.title
            ns.summary = row[2]
            ns.old_user_id = row[3]
            ns.rating_integer = row[4]
            rating_tag = ImportTag.new()
            rating_tag.tag_type = 7
            rating_tag.new_id = ns.rating_integer
            my_tag_list.push(rating_tag)
            ns.published =  row[5]
            cattag = ImportTag.new()
            if @use_proper_categories == true
              cattag.tag_type = 1
            else
              cattag.tag_type = 3
            end
            cattag.new_id = row[6]
            my_tag_list.push(cattag)
            subcattag = ImportTag.new()
            if @use_proper_categories == true
              subcattag.tag_type = 1
            else
              subcattag.tag_type = 3
            end
            subcattag.new_id =row[11]
            my_tag_list.push(subcattag)
            ns.updated = row[9]
            ns.completed = row[12]
            ns.hits = row[10]
          #efiction 3
          when 3
            ns.old_work_id = row[0]
            ns.title = row[1]
            ns.summary = row[2]
            ns.old_user_id = row[10]
            ns.rating_integer = row[4]
            rating_tag = ImportTag.new()
            rating_tag.tag_type =7
            rating_tag.new_id = ns.rating_integer
            tag_list.push(rating_tag)
            ns.published = row[8]
            ns.updated = row[9]
            ns.completed = row[12]
            ns.hits = row[10]

        end
#debug info

        puts "attempting to get new user id, user: #{ns.old_user_id}, source: #{ns.source_archive_id}"
#see if user / author exists for this import already

        a = ImportUser.new
        ns.new_user_id = self.get_new_user_id_from_imported(ns.old_user_id, @import_archive_id)
        puts "The New user id!!!! ie value at this point #{ns.new_user_id}"
        a = self.get_import_user_object_from_source(ns.old_user_id)
        if ns.new_user_id == 0
          puts "didnt exist in this import"
          ##get import user object from source database


          #see if user account exists in main archive by checking email,
          temp_author_id = get_user_id_from_email(a.email)

          if temp_author_id == 0 then
            #if not exist , add new user with user object, passing old author object
            new_a = ImportUser.new
            new_a = self.add_user(a)

            #pass values to new story object
            ns.penname = new_a.penname
            ns.new_user_id = new_a.new_user_id

            #debug info
            puts "newu 1"
            puts "newid = #{new_a.new_user_id}"

            #get newly created pseud id
            new_pseud_id = get_default_pseud_id(ns.new_user_id)

            #set the penname on newly created pseud to proper value
            update_record_target("update pseuds set name = '#{ns.penname}' where id = #{new_pseud_id}")
            a = new_a
            a.pseud_id = new_pseud_id
            update_record_target("insert into user_imports (user_id, pseud_id,source_archive_id,source_user_id) values (#{new_a.new_user_id},#{a.pseud_id},#{ns.source_archive_id},#{ns.old_user_id})")
          else
            #user exists, but is being imported
            #insert the mapping value
            puts "---existed"
            #update_record_target("insert into user_imports (user_id,source_archive_id,source_user_id) values (#{ns.new_user_id},#{ns.old_user_id},#{ns.source_archive_id})")
            #tempuser2 = User.find_by_id(ns.new_user_id)

            ns.penname = a.penname
            #check to see if penname exists as pseud for existing user
            temp_pseud_id = get_pseud_id_for_penname(temp_author_id,ns.penname)
            if temp_pseud_id == 0
              #add pseud if not exist
              begin
                new_pseud = Pseud.new
                new_pseud.user_id = temp_author_id
                new_pseud.name = a.penname
                new_pseud.is_default = true
                new_pseud.description = "Imported"
                new_pseud.save!
                temp_pseud_id = new_pseud.id

              rescue Exception=>e
                puts "Error: 111: #{e}"
              end
            begin
              new_ui = UserImport.new
              new_ui.user_id = temp_author_id
              new_ui.pseud_id = temp_pseud_id
              new_ui.source_user_id = ns.old_user_id
              new_ui.source_archive_id = ns.source_archive_id
              new_ui.save!
            rescue Exception=>e
              puts "Error: 777: #{e}"
            end





              'update_record_target("insert into pseuds (user_id,name,is_default,description) values (#{},'#{}',1,'Imported'")

              #return newly created pseud

             # 'temp_pseud_id = get_pseud_id_for_penname(ns.new_user_id,ns.penname)


              update_record_target("update user_imports set pseud_id = #{temp_pseud_id} where user_id = #{ns.new_user_id} and source_archive_id = #{@import_archive_id}")
              puts "====A"
              ns.new_user_id = temp_pseud_id
              a.pseud_id = temp_pseud_id
            end
          end

        else
              ns.penname = a.penname
              a.pseud_id = get_pseud_id_for_penname(ns.new_user_id,ns.penname)
          puts "#{a.pseud_id} this is the matching pseud id"
        end

        #insert work object
        begin
          new_work = Work.new
          new_work.title = ns.title
          new_work.summary = ns.summary
          new_work.authors_to_sort_on = ns.penname
          new_work.title_to_sort_on = ns.title
          new_work.restricted = true
          new_work.posted = true
          puts "looking for pseud #{a.pseud_id}"
          new_work.pseuds << Pseud.find_by_id(a.pseud_id)
          new_work.revised_at = ns.updated
          new_work.created_at = ns.published
          new_work.fandom_string = @import_fandom
          new_work.rating_string = "Not Rated"
          new_work.warning_strings = "None"
          new_work.errors.full_messages
          puts "old work id = #{ns.old_work_id}"


          new_work.imported_from_url = "#{@import_archive_id}~~#{ns.old_work_id}"
          new_work = add_chapters(new_work,ns.old_work_id)
          new_work.chapters.each do |chap|
            #puts "#{chap.title}"
          end
          #new_work.chapters.build
          new_work.save!
          new_work.chapters.each do |cc|
            puts "attempting to save chapter for #{new_work.id}"
            puts cc.content
            puts cc.title
            puts cc.posted
            puts cc.work_id
            puts cc.position
            cc.work_id = new_work.id
            #cc.save!
            cc.errors.full_messages
          end
           add_chapters2(ns,new_work.id)

          my_tag_list.each do |t|
             add_work_taggings(new_work.id,t)
          end
          puts "new work created #{new_work.id}"

        rescue Exception=>e
          puts "Error: 222: #{e}"

        end


=begin

        #self.update_record_target("Insert into works (title, summary, authors_to_sort_on, title_to_sort_on, revised_at, created_at, imported_from_url) values (
        #'#{ns.title}','#{ns.summary}','#{ns.penname}','#{ns.title}','#{ns.updated}','#{ns.published}', '#{@import_archive_id}~~#{ns.old_work_id}'); ")
        begin
          new_wc = Creatorship.new
          new_wc.creation_id = new_work.id
          new_wc.creation_type = "work"
          new_wc.pseud_id = ns.new_user_id
          new_wc.save!
          puts "new work creatorship #{new_wc.id}"


        rescue Exception=>e
          puts "Error: 333: #{e}"

        end


        new_wc = Creatorship.new
        new_wc.creation_id = new_work.id
        new_wc.creation_type = "work"
        new_wc.pseud_id = ns.new_user_id
        new_wc.save!
        puts "new work creatorship #{new_wc.id}"

=end


        begin
          new_wi = WorkImport.new
          new_wi.work_id = new_work.id
          new_wi.pseud_id = ns.new_user_id
          new_wi.source_archive_id = @import_archive_id
          new_wi.source_work_id = ns.old_work_id
          new_wi.source_user_id = ns.old_user_id

          new_wi.save!

        rescue Exception=>e
          puts "Error: 888: #{e}"
        end



      #return new work id
      #ns.new_work_id =  get_new_work_id_fresh(ns.old_work_id,ns.source_archive_id)
        #add creation
        #self.update_record_target("Insert into creatorships(creation_id, pseud_id, creation_type) values (#{ns.new_work_id},#{ns.new_user_id}, 'work') ")
        #                     puts "eee"
        connection.close()


      rescue Exception => ex
        puts " Error : " + ex.message
        connection.close()
      ensure
      end
      i = i + 1
    end
    connection.close()
  end

    def create_work_from_import_work(ns)

    end
  def add_work_tagging(work_id,tag)
    new_tagging = Tagging.new

  end
  def add_chapters2(ns,new_id)
    connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
    case @source_archive_type
      when 4
        puts "1121 == Select * from #{@source_chapters_table} where csid = #{ns.old_work_id} order by id asc"
        r = connection.query("Select * from #{@source_chapters_table} where csid = #{ns.old_work_id}")
        puts "333"
        ix = 1
        r.each do |rr|
          c = ImportChapter.new()
          c.new_work_id = new_id

          c.title = rr[1]
          c.date_posted = rr[4]
          c.body = rr[3]
          c.position = ix
          self.post_chapters(c, @source_archive_type)
        end
      when 3

    end

    connection.close()


  end

#copied and modified from mass import rake, stephanies 1/22/2012
#Create archivist and collection if they don't already exist"
 def create_archivist_and_collection

    # make the archivist user if it doesn't exist already
    u = User.find_or_initialize_by_login(@archivist_login)
    if u.new_record?
      u.password = @archivist_password
      u.email = @archivist_email
      u.save
    end
    unless u.is_archivist?
      u.roles << Role.find_by_name("archivist")
      u.save
    end
    # make the collection if it doesn't exist already
    c = Collection.find_or_initialize_by_name(@new_collection_name)
    if c.new_record?
      c.description = @new_collection_description
      c.title = @new_collection_title
    end
    # add the user as an owner if not already one
    unless c.owners.include?(u.default_pseud)
      p = c.collection_participants.where(:pseud_id => u.default_pseud.id).first || c.collection_participants.build(:pseud => u.default_pseud)
      p.participant_role = "Owner"
      c.save
      p.save
    end
    c.save
    @new_collection_id = c.id
    puts "Archivist #{u.login} set up and owns collection #{c.name}."
  end

  #Post Chapters Fix
  def post_chapters2(c, sourceType)
    case sourceType
      when 4
        new_c = Chapter.new
        new_c.work_id =  c.new_work_id
        new_c.created_at = c.date_posted
        new_c.updated_at = c.date_posted
        new_c.posted = 1
        new_c.position = c.position
        new_c.title = c.title
        new_c.summary = c.summary
        new_c.content = c.body
        new_c.save!

        puts "New chapter id #{new_c.id}"

        add_new_creatorship(new_c.id,"chapter",c.pseud_id)

    end
  end

  #add chapters    takes chapters and adds them to import work object
    def add_chapters(ns,old_work_id)
      connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
      case @source_archive_type
        when 4
          puts "1121 == Select * from #{@source_chapters_table} where csid = #{old_work_id}"
          r = connection.query("Select * from #{@source_chapters_table} where csid = #{old_work_id}")
          puts "333"
          ix = 1
          r.each do |rr|
            c = Chapter.new()
            #c.new_work_id = ns.new_work_id     will be made automatically
            #c.pseud_id = ns.pseuds[0]
            c.title = rr[1]
            c.created_at  = rr[4]
            #c.updated_at = rr[4]
            c.content = rr[3]
            c.position = ix
            c.summary = ""
            c.posted = 1
            ns.chapters << c

            ix = ix + 1
            #self.post_chapters(c, @source_archive_type)
          end
        when 3

      end

      connection.close()
      return ns

  end


#adds new creatorship
 def add_new_creatorship(creation_id,creation_type,pseud_id)
  new_creation = Creatorship.new()
  new_creation.creation_type = creation_type
  new_creation.pseud_id = pseud_id
  new_creation.creation_id = chapter_id
  new_creation.save!
  puts "New creatorship #{new_creation.id}"
 end



#Add User
  def add_user(a)
    begin
      login_temp = a.email.tr("@", "")
      login_temp = login_temp.tr(".","")
      #new user model
      new_user = User.new()
      new_user.terms_of_service = true
      new_user.email = a.email
      new_user.login = login_temp
      new_user.password = a.password
      new_user.password_confirmation = a.password
      new_user.age_over_13 = true
      new_user.save!

      #Create Default Pseud / Profile
      new_user.create_default_associateds
      a.new_user_id = new_user.id

      return a
    rescue Exception=>e
      puts "error 1010: #{e}"
    end

  end


  # Set Archive Strings and values # </summary> # <remarks></remarks>
  def set_import_strings
    case @source_archive_type
      when 1
        @source_chapters_table = "#{@source_table_prefix}chapters"
        @source_reviews_table = "#{@source_table_prefix}reviews"
        @source_stories_table = "#{@source_table_prefix}stories"
        @source_categories_table = "#{@source_table_prefix}categories"
        @source_users_table = "#{@source_table_prefix}authors"
        @get_author_from_source_query = " "
      when 2
        @source_chapters_table = "#{@source_table_prefix}chapters"
        @source_reviews_table = "#{@source_table_prefix}reviews"
        @source_stories_table = "#{@source_table_prefix}stories"
        @source_users_table = "#{@source_table_prefix}authors"
        @get_author_from_source_query = "Select realname, penname, email, bio, date, pass, website, aol, msn, yahoo, icq, ageconsent from  #{@source_users_table} where uid ="
      when 3
        @source_chapters_table = "#{@source_table_prefix}chapters"
        @source_reviews_table = "#{@source_table_prefix}reviews"
        @source_stories_table = "#{@source_table_prefix}stories"
        @source_users_table = "#{@source_table_prefix} authors"
        @get_author_from_source_query = "Select realname, penname, email, bio, date, pass from #{@source_users_table} where uid ="
      when 5
      when 4
        @source_chapters_table = "#{@source_table_prefix}chapters"
        @source_reviews_table = "#{@source_table_prefix}reviews"
        @source_stories_table = "#{@source_table_prefix}stories"
        @source_users_table = "#{@source_table_prefix}users"
        @source_categories_table = "#{@source_table_prefix}category"
        @source_subcategories_table = "#{@source_table_prefix}subcategory"
        @srcRatingsTable = "" #None
        @get_author_from_source_query = "SELECT urealname, upenname, uemail, ubio, ustart, upass, uurl, uaol, umsn, uicq from #{@source_users_table} where uid ="
    end
  end

  ##get import user object, by source_user_id
  def get_import_user_object_from_source(source_user_id)
    a = ImportUser.new()
    connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
    r = connection.query("#{@get_author_from_source_query} #{source_user_id}")
    connection.close

    r.each  do |r|
      a.old_user_id = source_user_id
      a.realname = r[0]
      a.source_archive_id = @import_archive_id

      a.penname = r[1]
      a.email = r[2]
      a.bio = r[3]
      a.joindate = r[4]
      a.password = r[5]
      if @source_archive_type == 2 || @source_archive_type == 4
        a.website = r[6]
        a.aol = r[7]
        a.msn = r[8]
        a.icq = r[9]
        a.bio = self.build_bio(a).bio
        a.yahoo = ""
        if @source_archive_type == 2
          a.yahoo = r[10]
          a.isadult = r[11]
        end
      end

    end



    return a
  end

# Consolidate Author Fields into User About Me String
  def build_bio(a)
    if a.yahoo == nil
      a.yahoo = " "
    end
    if a.aol.length > 1 || a.yahoo.length > 1 || a.website.length > 1 || a.icq.length > 1 || a.msn.length > 1
      if a.bio.length > 0
        a.bio << "<br /><br />"
      end
    end
    if a.aol.length > 1
      a.bio << " <br /><b>AOL / AIM :</b><br /> #{a.aol} "
    end
    if a.website.length > 1
      a.bio << "<br /><b>Website:</ b><br /> #{a.website} "
    end
    if a.yahoo.length > 1
      a.bio << "<br /><b>Yahoo :</b><br /> #{a.yahoo} "
    end
    if a.msn.length > 1
      a.bio << "<br /><b>Windows Live:</ b><br /> #{a.msn} "
    end
    if a.icq.length > 1
      a.bio << "<br /><b>ICQ :</b><br /> #{a.icq} "
    end
    return a
  end
#TODO


  #return old new id from user_imports table based on old user id & source archive
  def get_new_user_id_from_imported(old_id,source_archive)
    puts "#{old_id}"
    return get_single_value_target("select user_id from user_imports where source_user_id = #{old_id} and source_archive_id = #{source_archive}")
  end

  def get_default_pseud_id(user_id)
    return get_single_value_target("select id from pseuds where user_id = #{user_id}")
  end

  #given valid user_id search for psued belonging to that user_id with matching penname
  def get_pseud_id_for_penname(user_id,penname)
    puts "11-#{user_id}-#{penname}"
    return get_single_value_target("select id from pseuds where user_id = #{user_id} and name = '#{penname}'")
  end


  def get_new_work_id_fresh(source_work_id,source_archive_id)
    puts "13-#{source_work_id}~~#{source_archive_id}"
    return get_single_value_target("select id from works where imported_from_url = '#{source_work_id}~~#{source_archive_id}'")
  end

# Return new story id given old id and archive
  def get_new_work_id_from_old_id(source_archive_id, old_work_id) #
    puts "12-#{source_archive_id}-#{old_work_id}"
    return get_single_value_target(" select work_id from work_imports where source_archive_id #{source_archive_id} and old_work_id=#{old_work_id}")
  end

 # Get New Author ID from old User ID & old archive ID
  def get_new_author_id_from_old(old_archive_id, old_user_id)
   return get_single_value_target(" Select user_id from user_imports where source_archive_id = #{old_archive_id} and source_user_id = #{old_user_id} ")
  end

  #check for existing user by email address
  def get_user_id_from_email(emailaddress)
    return get_single_value_target("select id from users where email = '#{emailaddress}'")
  end

  def get_single_value_target(query)
    connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
    r = connection.query(query)
    connection.close
    if r.num_rows == 0
      return 0
    else
      r.each do |rr|
        return rr[0]
      end
    end
  end

# Update db record takes query as peram #
  def update_record_target(query)
    connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
    begin
      rowsEffected = 0
      rowsEffected = connection.query(query)

      connection.close()
      return rowsEffected
    rescue Exception => ex
      connection.close()
      puts ex.message
    ensure
    end
  end

# Update db record takes query as peram #
  def update_record_source(query)
    connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
    begin
      rowsEffected = 0

      rowsEffected = connection(query)
      connection.close()
      return rowsEffected
    rescue Exception => ex

      connection.close()

      puts ex.message
    end
  end

end
