#!/usr/bin/env rails script/runner

# usage:
=begin
RAILS_ENV=production rake db:drop
RAILS_ENV=production rake db:create
RAILS_ENV=production rails dbconsole -p < /backup/latest.dump
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake After
rm -f db/seed/*
RAILS_ENV=production rails runner script/seed_dump.rb
=end

BACKUPDIR = Rails.root.to_s + '/db/seed'

# users who have webdavs or asked to be added
# or who have problematic works which need testing
SEEDS = [
          "Anneli", "astolat", "Atalan", "awils1", "aworldinside", "bingeling",
          "Cesy", "cesytest", "Celandine", "Chandri", "ealusaid", "eel",
          "elz", "erda", "Enigel", "hope", "Jaetion", "justira", "jetta_e_rus",
          "lim", "Lisztful", "melange", "mumble", "Rebecca", "rklyne", "Rustler",
          "Sidra", "staranise", "Stowaway", "testy", "Tel", "tomatopudding",
          "zelempa", "zoemathemata", "Zooey_Glass", "zlabya",
]

# try to pick different types of collections and ones with challenges in different stages, if possible

COLLECTIONS = [

]

# Note: every NTH user (randomized) will have all their associated records dumped
# many more than that users will be in the database, however because of associations
# This number is also used to limit the number of readings, comments, and feedbacks
# this number should increase as the archive grows to keep the decimated database a reasonable size
NTH = 100

# private bookmarks and unpublished works are not selected in a multi-user dump
MULTI = true

## to dump just one user uncomment the following and replace the user name
## (you can either comment out the previous ones, or just ignore the already initialized warning)

#   SEEDS = [ "Sidra" ]
#   NTH = 1
#   MULTI = false

## this will select all their own works, comments, readings and bookmarks,
## even private ones, but not the associated works

### end of configuration

#### helper methods ####

# taken from http://zerobearing.com/2009/04/16/rails-activerecord-sql-insert-dump
class ActiveRecord::Base
  # add an "sql_show_insert" method to all active records
  def sql_show_insert
    "INSERT INTO #{self.class.quoted_table_name} (#{quoted_column_names.join(', ')}) VALUES(#{attributes_with_quotes.values.join(', ')});\n"
  end

  # FIXME find out current Arel methods, so don't have to re-add old rails 2 methods.
  # attributes_with_quotes => arel_attributes_values
  # but I couldn't find quoted_column_names
  def quoted_column_names(attributes = attributes_with_quotes)
    connection = self.class.connection
    attributes.keys.collect do |column_name|
      connection.quote_column_name(column_name)
    end
  end
  def attributes_with_quotes(include_primary_key = true, include_readonly_attributes = false, attribute_names = @attributes.keys)
    quoted = {}
    connection = self.class.connection
    attribute_names.each do |name|
      if (column = column_for_attribute(name)) && (include_primary_key || !column.primary)
        value = read_attribute(name)

        # We need explicit to_yaml because quote() does not properly convert Time/Date fields to YAML.
        if value && self.class.serialized_attributes.has_key?(name) && (value.acts_like?(:date) || value.acts_like?(:time))
          value = value.to_yaml
        end

        quoted[name] = connection.quote(value, column)
      end
    end
    include_readonly_attributes ? quoted : remove_readonly_attributes(quoted)
  end
  def remove_readonly_attributes(attributes)
    unless self.class.readonly_attributes.nil?
      attributes.delete_if { |key, value| self.class.readonly_attributes.include?(key.gsub(/\(.+/,"")) }
    else
      attributes
    end
  end
end

# take an instance and cleanse it,
# then write to a file the sql statement which would re-create it
def write_model(thing)
  file = thing.class.name.underscore + ".sql"
  # print out something (small) so we know things are happening
  initial = file.first
  print initial; STDOUT.flush

  # redact email addresses
  if thing.respond_to? :email
    if thing.respond_to? :login
      thing.email = "#{thing.login}-seed@ao3.org"
    else
      thing.email = "#{thing.class.name}-#{thing.id.to_s}-seed@ao3.org"
    end
  end

  # remove icons, because they just give broken links in development
  if thing.respond_to? :icon_file_name
    thing.icon_file_name = nil
    thing.icon_content_type = nil
    thing.icon_file_size = nil
  end

  # write SQL to file
  File.open(file, 'a') {|f| f.write(thing.sql_show_insert) }
end

### start work  ###

FileUtils.mkdir_p(BACKUPDIR)
FileUtils.chdir(BACKUPDIR)

USERS = []
WORKS = []
PSEUDS = []
TAGS = []

# the user is the starting point.
SEEDS.each do |seed|
  user = User.find_by_login(seed)
  USERS << user
end
# random Nth user
User.find_in_batches(:batch_size => NTH ) {|users| USERS << users.sample } if MULTI

# return an array of records associated with the users
# but keep the works, pseuds and tags for later
def user_associations(users)
  x = []
  users.each do |u|
    puts " collecting #{u.login}'s records"

    ## PSEUDS will dump the actual user record and the user's preferences
    ## so they don't need to be dumped here.
    PSEUDS << u.pseuds

    # the roles are all dumped separately, so just dump the association here
    x << u.roles_users

    x << u.profile unless MULTI   # profile's may have sensitive information that isn't visible

    TAGS << u.fandoms if u.tag_wrangler

    x << u.skins

    u.readings.find_in_batches(:batch_size => NTH) do |readings|
      x << readings.last
      WORKS << readings.last.work if MULTI
    end

    u.inbox_comments.find_in_batches(:batch_size => NTH) do |batch|
      inbox_comment = batch.last
      x << inbox_comment
      x << inbox_comment.feedback_comment
      commentable = inbox_comment.feedback_comment.ultimate_parent
      if MULTI
        if commentable.is_a?(Work)
          WORKS << commentable
        elsif commentable.is_a?(Tag)
          TAGS << commentable
        else
          x << commentable
        end
      end
      PSEUDS << inbox_comment.feedback_comment.pseud
      commentable = inbox_comment.feedback_comment.ultimate_parent
      WORKS << commentable if (MULTI && commentable.is_a?(Work))
    end

    # most of the associations are actually through the pseuds
    u.pseuds.each do |p|
      p.comments.find_in_batches(:batch_size => NTH) do |comments|
        comment = comments.last
        x << comment
        if MULTI
          commentable = comment.ultimate_parent
          if commentable.is_a?(Work)
            WORKS << commentable
          elsif commentable.is_a?(Tag)
            TAGS << commentable
          elsif commentable
            x << commentable
          end
        end
      end
      p.bookmarks.each do |bookmark|
        if !bookmark.private? || !MULTI
          x << bookmark
          x << bookmark.taggings
          TAGS << bookmark.tags
          if MULTI
            bookmarkable = bookmark.bookmarkable
            if bookmarkable.is_a?(Work)
              WORKS << bookmarkable
            elsif bookmarkable.is_a?(Series)
              x << bookmarkable
              bookmarkable.works.each {|w| WORKS << w}
            elsif bookmarkable.is_a?(ExternalWork)
              x << bookmarkable
              x << bookmarkable.taggings
              TAGS << bookmarkable.tags
            end
          end
        end
      end
      x << p.creatorships
      p.creatorships.map(&:creation).each do |item|
        if item.is_a?(Work)
          if item.posted? || !MULTI
            WORKS << item
            x << item.related_works
            item.related_works.each do |parent|
              if parent.is_a? Work
                WORKS << parent
              else
                x << parent
              end
            end
            x << item.parent_work_relationships
            item.children.each {|w| WORKS << w}
          end
        elsif item.is_a?(Chapter)
          # chapters get pulled in from works
        elsif item.is_a?(Series)
          x << item
        end
      end
      x << p.collections
      p.collections.each do |c|
        x << c.collection_profile
        x << c.collection_preference
        x << c.collection_participants
        PSEUDS << c.collection_participants.map(&:pseud)
      end
    end
  end
  x.flatten.compact.uniq
end

# For these users only, get all their associated records
puts ""
puts "Dumping records for #{USERS.compact.uniq.size} users (minus WORKS, PSEUDS & TAGS)"
user_associations(USERS.compact.uniq).each {|item| write_model(item)}

## Now deal with WORKS, PSEUDS, and TAGS.
## WORKS first, because it adds more to PSEUDS and TAGS

# return an array of records associated with the works
# but keep the pseuds and tags for later
def work_associations(items)
  puts " collecting work associations"
  x = []
  items.each do |work|
    print "."; STDOUT.flush
    next unless (!work.unrevealed? && work.posted?) || !MULTI
    x << work.taggings
    TAGS << work.tags
    x << work.creatorships
    PSEUDS << work.pseuds
    x << work
    x << work.language
    x << work.hit_counter
    x << work.gifts
    PSEUDS << work.gifts.map(&:pseud)
    x << work.kudos
    PSEUDS << work.kudos.map(&:pseud)
    x << work.collection_items
    x << work.collections
    work.collections.each do |c|
      x << c.collection_profile
      x << c.collection_preference
      x << c.collection_participants
      PSEUDS << c.collection_participants.map(&:pseud)
    end
    x << work.serial_works
    x << work.series
    work.chapters.each do |c|
      x << c if c.posted? || !MULTI
      PSEUDS << c.pseuds
      x << c.comments
      PSEUDS << c.comments.map(&:pseud)
      x << c.kudos
      PSEUDS << c.kudos.map(&:pseud)
    end
  end
  x.flatten.compact.uniq
end

puts ""
puts "Dumping records for #{WORKS.compact.uniq.size} works (minus PSEUDS & TAGS)"
work_associations(WORKS.compact.uniq).each {|item| write_model(item)}

# return an array of records associated with the tags
def tag_assocations(tags)
  x = []
  tags.each do |t|
    print "."; STDOUT.flush
    TAGS << t
    PSEUDS << t.last_wrangler.pseuds if t.last_wrangler.is_a? User
    TAGS << t.merger
    x << t.common_taggings
    TAGS << t.parents
    x << t.meta_taggings
    TAGS << t.meta_tags
  end
  x.flatten.compact.uniq
end

original_tags = TAGS.flatten.compact.uniq
puts ""
puts "Dumping records for the associations for #{original_tags.size} tags (minus PSEUDS)"
tag_assocations(original_tags).each {|item| write_model(item)}

new_tags = TAGS.flatten.compact.uniq - original_tags
puts ""
puts "Dumping records for the associations for #{new_tags.size} more tags (minus PSEUDS)"
tag_assocations(new_tags).each {|item| write_model(item)}

more_tags = TAGS.flatten.compact.uniq - original_tags - new_tags
puts ""
puts "Dumping records for the associations for #{more_tags.size} more tags (minus PSEUDS)"
tag_assocations(new_tags).each {|item| write_model(item)}

# stop after three levels of tags, that's enough wrangling for a decimated database
puts ""
puts "Dumping records for #{TAGS.flatten.compact.uniq.size} tags"
TAGS.flatten.compact.uniq.each {|tag| write_model(tag)}

# return an array of records associated with the pseuds
def pseud_associations(pseuds)
  puts " collecting pseud associations"
  x = []
  pseuds.each do |p|
    print "."; STDOUT.flush
    x << p
    x << p.user
    x << p.user.preference
  end
  x
end

puts ""
puts "Dumping records for #{PSEUDS.flatten.compact.uniq.size} pseuds"
pseud_associations(PSEUDS.flatten.compact.uniq).each {|item| write_model(item)}


# dump models not directly associated with users
if MULTI
  # roles are associated with users, but we need them all
  puts ""
  puts "Dumping roles"
  Role.find_each {|r| write_model(r)}
  puts ""
  puts "Dumping all admins and admin settings"
  Admin.find_each {|a| write_model(a)}
  write_model(AdminSetting.first)
  Skin.where(:official => true).each{|s| write_model(s)}
  puts ""
  puts "Dumping all docs"
  AdminPost.find_each {|p| write_model(p)}
  ArchiveFaq.find_each {|f| write_model(f)}
  KnownIssue.find_each {|ki| write_model(ki)}
  puts ""
  puts "Dumping every #{NTH} feedback"
  Feedback.find_in_batches(:batch_size => NTH ) {|b| write_model(b.last)}
end

puts ""
puts "Done!"
