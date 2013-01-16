class MassImportTool
  require "mysql"

  def initialize()
    #Import Class Version Number
    @Version = 1

    #not using for testing
    #import config filename
    #@config = OTW.Settings.INIFile.new("config.ini") #'
    #temporary table prefix
    @temptableprefix = "temp321"
    #####################################################

    #Match Existing Authors by Email-Address
    @match_existing_authors = true

    #Import Job Name
    @import_name = "New Import"

    #Create record for imported archive (false if already exists)
    @create_import_archive_record = true

    #Import Archive ID
    @import_archive_id = 100

    #Import reviews t/f
    @import_reviews = true

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
    @new_collection_id = -1

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
    @source_ratings_table = ""

    #Source Users Table
    @source_users_table = ""

    #Source Stories Table
    @source_stories_table = ""

    #Source Reviews Table
    @source_reviews_table = ""

    #Source Chapters Table
    @source_chapters_table = ""

    #Source Characters Table
    @source_characters_table = ""

    #Source Subcategories Table
    @source_subcatagories_table = ""

    #Source Categories Table
    @source_categories_table = ""

    #string holder
    @get_author_from_source_query = ""

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

    self.update_record_source("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_1} where  #{rating_field_name} = 1;")
    self.update_record_source("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_2} where  #{rating_field_name} = 2;")
    self.update_record_source("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_3} where  #{rating_field_name} = 3;")
    self.update_record_source("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_4} where  #{rating_field_name} = 4;")
    self.update_record_source("update #{@source_stories_table} set #{rating_field_name}= #{@target_rating_5} where #{rating_field_name} = 5;")
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

  #get all possible tags from source
  def get_tag_list(tl, at)
    taglist = tl
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")

    case at
      #storyline
      when 4
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
      #efiction 3
      when 3
        r = connection.query("Select class_id, class_type, class_name from #{@source_table_prefix}classes; ")
        r.each do |r|
          nt = ImportTag.new()
          if r[1] == @srcWarningClassTypeID
            nt.tag_type = 6
          else
            nt.tag_type = 3
          end
          nt.old_id = r[0]
          nt.tag = r[2]
          taglist.push(nt)
        end

        rr = connection.query("Select catid, category from #{@source_table_prefix}categories; ")
        rr.each do |rr|
          nt = ImportTag.new()
          nt.tag_type = 1
          nt.old_id = rr[0]
          nt.tag = rr[1]
          taglist.push(nt)

        end

        rrr = connection.query("Select charid, charname from #{@source_table_prefix}characters; ")
        rrr.each do |rrr|
          nt = ImportTag.new()
          nt.tag_type = 2
          nt.old_id = rrr[0]
          nt.tag = rrr[1]
          taglist.push(nt)
        end
      when ArchiveType.efiction2
    end
    connection.close()
    return taglist
  end


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


  def create_collection(name,owner)
   #TODO
    collect = Collection.new()
      collect.name = @new_collection_name
      collect.description = @new_collection_description
      collect.title = new_collection_title

  end

  ##################################################################################################
  # Main Worker Sub
  def import_data()
    #create collection


    puts " Setting Import Values "
    self.set_import_strings()

    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")

    if @skip_rating_transform == false
      puts " Tranforming source ratings "
      self.transform_source_ratings()
    else
      puts " Skipping source rating transformation per config "
    end

    #Update Tags and get Taglist
    puts (" Updating Tags ")
    tag_list = Array.new()
    #tag_list2 = self.get_tag_list(tag_list, @source_archive_type)
    tag_list = self.fill_tag_list(tag_list)
    if @debug_update_source_tags == true
      self.update_source_tags(tag_list)
    end

    r = connection.query("SELECT * FROM #{@source_stories_table} ;")
    connection.close()
    puts (" Importing Stories ")
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
        ns.new_user_id = self.get_new_user_id_from_imported(ns.old_user_id, ns.source_archive_id)
        if ns.new_user_id == 0
          ##get import user object from source database
          a = ImportUser.new
          a = self.get_import_user_object_from_source(ns.old_user_id)
          #see if user account exists by checking email,
          temp_author_id = get_user_id_from_email(a.email)
          if temp_author_id == 0 then
            #if not exist , add new user with user object, passing old author object
            new_a = ImortUser.new
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
            update_record_target("insert into user_imports (user_id,source_archive_id,source_user_id) values (#{ns.new_user_id},#{ns.old_user_id},#{ns.source_archive_id})")
          else
            #user exists, but is being imported
            #insert the mapping value
            puts "---e"
            update_record_target("insert into user_imports (user_id,source_archive_id,source_user_id) values (#{ns.new_user_id},#{ns.old_user_id},#{ns.source_archive_id})")
            ns.penname = a.penname
            #check to see if penname exists as pseud for existing user
            temp_pseud_id = get_pseud_id_for_penname(temp_author_id,ns.penname)
            if temp_pseud_id == 0
              #add pseud if not exist
              update_record_target("insert into pseuds (user_id,name,is_default,description) values (#{temp_author_id},'#{a.penname}',1,'Imported'")

              #return newly created pseud
              puts "---b"
              temp_pseud_id = get_pseud_id_for_penname(ns.new_user_id,ns.penname)
              puts "----c"
              update_record_target("update user_imports set pseud_id = #{ns.new_user_id} where user_id = #{ns.new_user_id} and source_archive_id = #{ns.source_archive_id}")
              puts "====A"
              ns.new_user_id = temp_pseud_id
            end
          end
        end
        #insert work object
        self.update_record_target("Insert into works (title, summary, authors_to_sort_on, title_to_sort_on, revised_at, created_at, imported_from_url) values ('#{ns.title}','#{ns.summary}','#{ns.penname}','#{ns.title}','#{ns.updated}','#{ns.published}', '#{@import_archive_id}~~#{ns.old_work_id}'); ")
                    puts "yy"
      #return new work id
      ns.new_work_id =  get_new_work_id_fresh(ns.old_work_id,ns.source_archive_id)
        #add creation
        self.update_record_target("Insert into creatorships(creation_id, pseud_id, creation_type) values (#{ns.new_work_id},#{ns.new_user_id}, 'work') ")
                             puts "eee"
        connection.close()
        self.add_chapters(ns)

      rescue Exception => ex
        puts " Error : " + ex.message
        connection.close()
      ensure
      end
      i = i + 1
    end
    connection.close()
  end



    #add chapters
    def add_chapters(ns)
      connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")
      case @source_archive_type
        when 4
          r = connection.query = "Select * from #{@source_chapters_table} where csid = #{ns.old_work_id}"
          ix = 1
          r.each do |rr|
            c = ImportChapter.new()
            c.new_work_id = ns.new_work_id
            c.new_pseud_id = ns.new_user_id
            c.title = rr[1]
            c.dateposted = rr[4]
            c.body = rr[3]
            c.position = ix
            self.post_chapters(c, @source_archive_type)
          end
        when 3

      end

      connection.close()


  end

    def post_chapters(c, sourceType)
      case sourceType
        when 4
          self.update_record_target("Insert into Chapters (content, work_id, created_at, updated_at, posted, title, published_at,position) values ('#{c.body}', '#{c.dateposted.ToString}', '#{c.dateposted.ToString}', 1,'#{c.title}', '#{c.dateposted.ToString}',#{c.position}) ")
          self.update_record_target("Insert into creatorships(creation_id, pseud_id, creation_type) values (#{c.new_chapter_id},#{c.newUserId},'chapter') ")
      end
    end




#Structures
################
  ImportTag = Struct.new(:old_id,:new_id,:tag,:tag_type)

  ImportUser = Struct.new(:old_username, :penname,:realname,:joindate,:source_archive_id,:old_user_id,:bio,:password,
                          :password_salt,:website,:aol,:yahoo,:msn,:icq,:new_user_id,:email,:is_adult)

  ImportChapter = Struct.new(:new_chapter_id,:new_work_id,:old_story_id,:source_archive_id,:title,:new_pseud_id,
                             :summary,:notes,:old_user_id,:body,:position,:date_added)

  ImportWork = Struct.new(:old_story_id,:new_work_id,:author,:title,:summary,:classes,:old_user_id,:characters,
                          :hits,:new_author_id,:word_count,:completed,:updated,:source_archive_id,:generes,:rating,
                          :rating_integer,:warnings,:chapters,:published,:cats)



#Add User
  def add_user(a)
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
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")
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
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")
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
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")
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
    connection = Mysql.new("localhost","stephanies","Trustno1","stephanies_development")
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