class MassImportTool
  require "mysql"

  def initialize()
    #Import Class Version Number
    @Version = 1

    #import config filename
    #@config = OTW.Settings.INIFile.new("config.ini") #'

    #temporary table prefix
    @temptableprefix = "temp321"

    # Boolean Options #If true, send invites unconditionaly,
    # if false add them to the que to be sent when it gets to it, could be delayed.
    @bypassInviteQueForImported = true

    #Create collection for imported works?
    @create_collection = true

    #Match Existing Authors by Email-Address
    @matchExistingAuthors = true

    #Import Job Name
    @import_name = "New Import"

    #Import Archive ID
    @import_archive_id = 100

    #Import categories as categories or use ao3 cats
    @useProperCategories = false

    #Create record for imported archive
    @CreateImportArchiveRecord = false

    #Import reviews t/f
    @import_reviews = true

    #If using ao3 cats, sort or skip
    @SortForAo3Categories = true

    #New Collection Name
    @new_collection_name = "New Collection"

    #New Collection Description
    @new_collection_description = "Something here"

    #Send notification email with invitation to archive to imported users
    @notify_imported_users = true

    #Send message for each work imported? (or 1 message for all works)
    @send_individual_messages = false

    #Message to send existing authors
    @existing_notification_message = ""

    #message to be sent to users with no ao3 account
    @new_notification_message = ""

    #ID Of the newly created collection, filled with value automatically if create collection is true
    @new_collection_id = -1

    #Owner for created collection
    @new_collection_owner = "Stephanie"

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
    #
    #target db connection string
    @target_database_connection = "'localhost','stephanies','password','stepahanies_development'"

    #Source Variables
    ##################

    #Source DB Connection
    #"thepotionsmaster.net","test1","Trustno1","sltest" = "\"thepotionsmaster.net\",\"sltest\",\"test1\",\"password\""

    #Source Archive Type
    @source_archive_type = 4

    #If archivetype being imported is efiction 3 >  then specify what class holds warning information
    @source_warning_class_id = 1

    #Holds Value for source table prefix
    @source_table_prefix = "SL18_"

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

    #Skip Rating Transformation (ie if import in progress or testing)
    @skip_rating_transform = true
  end



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

  def DisplayStartupInfo()
    puts "AO3 Importer Starting "
    puts "Version #{@Version}"
    puts "Running: #{@import_name}"
  end




# Convert Source DB Ratings to those of target archive in advance
  def transform_source_ratings()
    case @source_archive_type
      when 4
        self.update_record_src("update #{@source_stories_table} set srating= #{@target_rating_1} where srating = 1;")
        self.update_record_src("update #{@source_stories_table} set srating= #{@target_rating_2} where srating = 2;")
        self.update_record_src("update #{@source_stories_table} set srating= #{@target_rating_3} where srating = 3;")
        self.update_record_src("update #{@source_stories_table} set srating= #{@target_rating_4} where srating = 4;")
        self.update_record_src("update #{@source_stories_table} set srating= #{@target_rating_5} where srating = 5;")

      when 3
        self.update_record_src("update #{@source_stories_table} set rid= #{@target_rating_1} where rid=1;")
        self.update_record_src("update #{@source_stories_table} set rid= #{@target_rating_2} where rid=2;")
        self.update_record_src("update #{@source_stories_table} set rid= #{@target_rating_3} where rid=3;")
        self.update_record_src("update #{@source_stories_table} set rid= #{@target_rating_4} where rid=4;")
        self.update_record_src("update #{@source_stories_table} set rid= #{@target_rating_5} where rid=5;")
      when ArchiveType.efiction2
    end
  end

  def fill_tag_list(tl)
    i = 0
    while i <= tl.Count - 1
      temptag = self.tl[i]
      connection = mysql.new(@target_database_connection)

      query = "Select id from tags where name = '#{temptag.Tag}'; "
      r = connection.query(query)
      if r.num_rows == 0 then
        self.update_record_target("Insert into tags (name, type) values ('#{temptag.Tag}','#{temptag.TagType}');")
        temptag.NewId = connection.query("SELECT last_insert_id() ")
      else
        temptag.NewId = r[0]
      end
      connection.Close()
      self.tl[i] = temptag
      i = i + 1
    end
    return tl
  end

  def get_tag_list(tl, at)
    taglist = tl
    connection = mysql.new("thepotionsmaster.net","test1","Trustno1","sltest")
    case at
      when 4
        query = "Select caid, caname from #{@source_table_prefix}category; " #
        r = connection.query(query)
        r.each do |r|
          nt = NewOtwTag.new()
          nt.TagType = TagType.Category
          nt.OldID = r[0]
          nt.Tag = r[1]
          taglist.Add(nt)
        end
        r.Clear()

        query2 = "Select subid, subname from #{@source_table_prefix}subcategory; "
        rr = connection.query(query2)
        rr.each do |rr|
          nt = NewOtwTag.new()
          nt.TagType = OtwTagType.SubCategory
          nt.OldID = rr[0]
          nt.Tag = rr[1]
          taglist.Add(nt)
        end
      when 3
        query = "Select class_id, class_type, class_name from #{@source_table_prefix}classes; " #
        r = connection.query(query)
        r.each do |r|
          nt = NewOtwTag.new()
          if r[1] == @srcWarningClassTypeID
            nt.TagType = OtwTagType.Warning
          else
            nt.TagType = OtwTagType.FreeForm
          end
          nt.OldID = r[0]
          nt.Tag = r[2]
          taglist.Add(nt)
        end
        query2 = "Select catid, category from #{@source_table_prefix}categories; "
        rr = connection.query(query2)
        rr.each do |rr|
          nt = NewOtwTag.new()
          nt.TagType = OtwTagType.Category
          nt.OldID = rr[0]
          nt.Tag = rr[1]
          taglist.Add(nt)

        end
        query3 = "Select charid, charname from #{@source_table_prefix}characters; "
        rrr = connection.query(query3)
        rrr.each do |rrr|
          nt = NewOtwTag.new()
          nt.TagType = OtwTagType.Character
          nt.OldID = rrr.Rows(i).Item(0)
          nt.Tag = rrr.Rows(i).Item(1)
          taglist.Add(nt)
        end
      when ArchiveType.efiction2
    end
    connection.Close()
    return taglist
  end



  def update_source_tags(tl)
    case srcArchiveType
      when 4
        Console.WriteLine(" Updating tags in source database for Archive Type 'StoryLine' ")
        i = 0
        i = 0
        while i <= tl.Count - 1
          currentTag = self.tl(i)
          if currentTag.TagType == OtwTagType.Category
            self.update_record_source("update #{@source_stories_table} set scid = #{currentTag.NewId} where scid = #{currentTag.OldID}")
          end
          if currentTag.TagType == OtwTagType.SubCategory
            self.updateRecordSRC(" update #{@source_stories_table} set ssubid = #{currentTag.NewId}  where ssubid = #{currentTag.OldID}")
          end
          i = i + 1
        end
      when 3
    end
  end



  # <summary> # Main Worker Sub # </summary> # <remarks></remarks>
  def import_data()
    puts " Setting Import Values "
    self.set_import_strings()
    query = " SELECT * FROM #{@source_stories_table} ;"
    connection = Mysql.new("thepotionsmaster.net","test1","Trustno1","sltest")

    if skip_rating_transform == false
      puts " Tranforming source ratings "
      self.transform_source_ratings()
    else
      puts " Skipping source rating transformation per config "
    end

    #Update Tags and get Taglist
    puts (" Updating Tags ")
    tag_list = Array.new()
    tag_list2 = self.get_tag_list(tag_list, @source_archive_type)
    tag_list = self.fill_tag_list(tage_list)
    self.update_source_tags(tag_list)
    r = connection.query(query)

    puts (" Importing Stories ")
    i = 0
    while i <= r.num_rows
      puts " Importing Story " + i + 1 + " of " * r.num_rows
      ns = ImportStory.new()
      a = ImportUser.new()
      #Create Taglisit for this story
      myTagList = Array.new()
      begin
        case srcArchiveType
          when 4
            ns.OldSid = r[0]
            ns.title = r[1]
            ns.summary = r[2]
            ns.AuthOldID = r[3]
            ns.RatingInt = r[4]
            rating_tag = NewOtwTag.new()
            rating_tag.TagType = OtwTagType.Rating
            rating_tag.NewId = ns.RatingInt
            myTagList.Add(rating_tag)

            ns.Published =  r[5]

            cattag = NewOtwTag.new()
            if useProperCategories == true
              cattag.TagType = OtwTagType.Category
            else
              cattag.TagType = OtwTagType.FreeForm
            end
            cattag.NewId = r[6]
            myTagList.Add(cattag)
            subcattag = NewOtwTag.new()
            if useProperCategories == true
              subcattag.TagType = OtwTagType.Category
            else
              subcattag.TagType = OtwTagType.FreeForm
            end
            subcattag.NewId =r[11]
            myTagList.Add(subcattag)
            ns.Updated = r[9]
            ns.Completed = r[12]
            ns.hits = r[10]
          when 3
            ns.OldSid = r[0]
            ns.title = r[1]
            ns.summary = r[2]
            ns.AuthOldID = r[10]
            ns.RatingInt = r[4]
            rating_tag = NewOtwTag.new()
            rating_tag.TagType = OtwTagType.Rating
            rating_tag.NewId = ns.RatingInt
            tag_list.Add(rating_tag)

            ns.Published = r[8]

            ns.Updated = r[9]
            ns.Completed = r[12]
            ns.hits = r[10]
          when ArchiveType.efiction2
          when ArchiveType.OTW
        end
        ns.NewAuthId = self.getauthorIDbyOld(ns.AuthOldID, ns.StoryArchive, ArchiveType.OTW)
        if ns.NewAuthId == 0
          a = self.getAuthorObjectFromSRC(ns.AuthOldID)
          newA = self.AddOTWAuthor(a)
          ns.NewAuthId = newA.defaultPsuid
          ns.Author = newA.PenName
        end
        self.update_record_target("Insert into works (title, summary, authors_to_sort_on, title_to_sort_on, revised_at, created_at, srcArchive, srcID) values ('" + ns.title + "', '" + ns.summary + "', '" + ns.Author + "', '" + ns.title + "', '" + ns.Updated + "', '" + ns.Published + "', " + ImportArchiveID + ", " + ns.OldSid + "); ")

        tgtConnection = Mysql.new(@target_database_connection)

        rr=tgtconnection.Query("select id from works where srcid = #{ns.OldSid} and srcArchive = #{@import_archive_id}")
        ns.NewSid = rr[0] #create creatorship
        self.update_record_target("Insert into creatorships(creation_id, pseud_id, creation_type) values (" + ns.NewSid + ", " + ns.NewAuthId + ", 'work') ") #ADD CHAPTERS
        tgtConnection.Close()

        connection.Close()
        self.AddChaptersOTW(ns)
      rescue Exception => ex
        puts " Error : " + ex.Message
        connection.Close()
      ensure
      end
      i = i + 1
    end
    connection.Close()
  end
=begin
    #Check For Author
    def AddChaptersOTW(ns)
      connection = MySqlConnection.new()
      connection.ConnectionString = srcDBCON
      chapCmd = MySqlCommand.new()
      chapCmd.Connection = connection
      chapCmd.CommandText = " Select * from " + srcTablePrefix + " chapters where csid = " + ns.OldSid
      chapDT = DataTable.new()
      connection.Open()
      reader = chapCmd.ExecuteReader
      chapDT.Load(reader)
      ixxi = 0
      ixxi = 0
      while ixxi <= chapDT.Rows.Count - 1
        c = Chapter.new()
        c.newSid = ns.NewSid
        c.newUserId = ns.NewAuthId
        c.title = chapDT.Rows(ixxi).Item(1)
        c.dateposted = chapDT.Rows(ixxi).Item(4)
        c.body = chapDT.Rows(ixxi).Item(3)
        self.PostChapterOTW(c, srcArchiveType)
        ixxi = ixxi + 1
      end
      connection.Close()
      reader.Close()
    end

    def post_chapters(c, sourceType)
      case sourceType
        when 4
          self.update_record_target("Insert into Chapters (content, work_id, created_at, updated_at, posted, title, published_at) values ('" + c.body + "', '" + c.dateposted.ToString + "', '" + c.dateposted.ToString + "', 1, '" + c.title + "', '" + c.dateposted.ToString + "') ")
          self.update_record_target("Insert into creatorships(creation_id, pseud_id, creation_type) values (" + c.newSid + ", " + c.newUserId + ", 'chapter') ")


      end
    end
=end

  ImportAuthor = Struct.new(:old_username, :penname,:realname,:joindate,:source_archive_id,:old_user_id,:bio,:password,
                            :password_salt,:website,:aol,:yahoo,:msn,:icq,:new_user_id,:email,:is_adult)

  ImportChapter = Struct.new(:new_work_id,:old_story_id,:source_archive_id,:title,
                             :summary,:notes,:old_user_id,:body,:position,:date_added)

  class NewOtwTag
    def initialize()
    end
    #Old Tag ID #New Tag ID #Tag
  end #Tag Type

  def get_user_id_from_email(email)
    connection = Mysql.new(@target_database_connection)
    r = connection.query("select user_id from users where email = '#{email}'")
    return r[0]
  end

  def add_user(a)
    new_user = user.create(email:"#{a.email}",login:"#{a.email}",password:"#{a.password}",confiirmpassword:"#{a.password}")
    new_user.create_default_associateds
    a.new_user_id = new_user.id
=begin
        #self.update_record_target("insert into users (email, login) values ('#{a.email}', '#{a.email}'); ")
        #a.new_user_id = self.get_user_id_from_email(a.email)
        #a.newuid = self.getauthorIDbyOld(a.source_archive_id, a.srcuid, ArchiveType.OTW)
        #self.update_record_target("Insert into profiles (user_id, about_me) values ( #{a.newuid},'#{a.bio}'); ")
        #self.update_record_target("Insert into pseuds (user_id, name, description, is_default) values (#{a.newuid}, '#{a.PenName}', 'Imported Pseudonym', 1); ")
        #self.update_record_target("Insert into preferences (user_id) values (#{a.newuid}); ")
        self.update_record_target("Insert into user_imports (user_id,source_user_id,source_archive_id,source_penname) values (#{a.newuid},#{a.source_archive_id},#{a.source_user_id}")
        cmd.CommandText = "Select id from users where source_archive_id = #{@import_archive_id} and srcid = #{a.srcuid}"
        a.newuid = r2.Rows(0).Item(0)
        cmd.CommandText = "Select id from pseuds where user_id = #{a.newuid} and is_default = 1 "
        a.defaultPsuid = r2.Rows(0).Item(0)
        connection.Close()
=end
    return a

  end
  # <summary> # Set Archive Strings and values # </summary> # <remarks></remarks>
  def set_import_strings
    case @source_archive_type
      when 1
        @source_chapters_table = "#{@source_table_prefix} chapters"
        @source_reviews_table = "#{@source_table_prefix} reviews"
        @source_stories_table = "#{@source_table_prefix} stories"
        @source_categories_table = "#{@source_table_prefix} categories"
        @source_users_table = "#{@source_table_prefix} authors"
        @get_author_from_source_query = " "
      when 2
        @source_chapters_table = "#{@source_table_prefix} chapters"
        @source_reviews_table = "#{@source_table_prefix} reviews"
        @source_stories_table = "#{@source_table_prefix} stories"
        @source_users_table = "#{@source_table_prefix} authors"
        @get_author_from_source_query = "Select realname, penname, email, bio, date, pass, website, aol, msn, yahoo, icq, ageconsent from  #{@source_users_table} where uid ="
      when 3
        @source_chapters_table = "#{@source_table_prefix} chapters"
        @source_reviews_table = "#{@source_table_prefix} reviews"
        @source_stories_table = "#{@source_table_prefix} stories"
        @source_users_table = "#{@source_table_prefix} authors"
        @get_author_from_source_query = "Select realname, penname, email, bio, date, pass from #{@source_users_table} where uid ="
      when 5
      when 4
        @source_chapters_table = "#{@source_table_prefix} chapters"
        @source_reviews_table = "#{@source_table_prefix} reviews"
        @source_stories_table = "#{@source_table_prefix} stories"
        @source_users_table = "#{@source_table_prefix} users"
        @source_categories_table = "#{@source_table_prefix} category"
        @source_subcategories_table = "#{@source_table_prefix} subcategory"
        @srcRatingsTable = "" #None
        @get_author_from_source_query = "SELECT urealname, upenname, uemail, ubio, ustart, upass, uurl, uaol, umsn, uicq from #{@source_users_table} where uid ="
    end
  end

  def get_imported_author_from_source(authid)
    a = ImportedAuthor.new()
    connection = Mysql.new("thepotionsmaster.net","test1","Trustno1","sltest")
    r = my.query("#{qryGetAuthorFromSource} #{authid}")
    r.each_hash do |r|
      a.srcuid = authid
      a.RealName = r["realname"]
      a.source_archive_id = @importArchiveID
      a.PenName = r["penname"]
      a.email = r["email"]
      a.Bio = r[3]
      a.joindate = r[4]
      a.password = r[5]
      if @source_archive_type == ArchiveType.efiction2 || @source_archive_type == ArchiveType.storyline
        a.website = r[6]
        a.aol = r[7]
        a.msn = r[8]
        a.icq = r[9]
        a.Bio = self.build_bio(a).Bio
        a.yahoo = ""
        if srcArchiveType == ArchiveType.efiction2
          a.yahoo = r[10]
          a.isadult = r[11]
        end
      end

    end
    my.free
    return a
  end

# Consolidate Author Fields into User About Me String
  def build_bio(a)
    if a.yahoo == nil
      a.yahoo = " "
    end
    if a.aol.Length > 1 | a.yahoo.Length > 1 | a.website.Length > 1 | a.icq.Length > 1 | a.msn.Length > 1
      if a.Bio.Length > 0
        a.Bio << "<br /><br />"
      end
    end
    if a.aol.Length > 1
      a.Bio << " <br /><b>AOL / AIM :</b><br /> #{a.aol} "
    end
    if a.website.Length > 1
      a.Bio << "<br /><b>Website:</ b><br /> #{a.website} "
    end
    if a.yahoo.Length > 1
      a.Bio << "<br /><b>Yahoo :</b><br /> #{a.yahoo} "
    end
    if a.msn.Length > 1
      a.Bio << "<br /><b>Windows Live:</ b><br /> #{a.msn} "
    end
    if a.icq.Length > 1
      a.Bio << "<br /><b>ICQ :</b><br /> #{a.icq} "
    end
    return a
  end
#TODO

# <summary> # Converts d/m/y to m/d/y # </summary> #
  def tppDateFix(dv)
    s = dv.Split("/")
    nd = self.s(1) + "/" + self.s(0) + "/" + self.s(2)
    return nd
  end

  # <summary> # Return new story id given old id and archive #
  def get_new_story_id_from_old_id(source_archive_id, old_story_id) #
    query = " select work_id from work_imports where source_archive_id #{source_archive_id} and old_story_id=#{old_story_id}"
    connection = Mysql.new(@target_database_connection)

    r = Mysql.query(query)
    if r.num_rows > 0
      return r[0]
    else
      return r.num_rows
    end

    connection.Close()

  end

  # Get New Author ID from old User ID & old archive ID
  def get_new_author_id_from_old(old_archive_id, old_user_id)
    begin
      connection = Mysql.new(@target_database_connection)
      query = " Select user_id from user_imports where source_archive_id = #{old_archive_id} and source_user_id = #{old_user_id} "
      r = connection.query(query)
      if r.num_rows == 0
        return 0
      else
        return r[0]
      end
    rescue Exception => ex
      connection.Close()
    ensure
    end
  end

# Update db record takes query as peram #
  def update_record_target(query)
    connection = Mysql.new(@target_database_connection)
    begin
      rowsEffected = 0
      rowsEffected = mysql.query(query)
      connection.free
      return rowsEffected
    rescue Exception => ex
      if connection.State != ConnectionState.Closed
        connection.free
      end
      puts ex.Message
    ensure
    end
  end

# Update db record takes query as peram #
  def update_record_src(query)
    connection = Mysql.new("thepotionsmaster.net","test1","Trustno1","sltest")
    begin
      rowsEffected = 0

      rowsEffected = mysql.query(query)
      connection.Close()
      return rowsEffected
    rescue Exception => ex
      if connection.State != ConnectionState.Closed
        connection.Close()
      end
      puts ex.Message
    end
  end

end