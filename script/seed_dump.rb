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
          "Cesy", "cesytest", "Celandine", "Chandri", "eel",
          "elz", "erda", "Enigel", "hope", "Jaetion", "justira", "jetta_e_rus",
          "lim", "Lisztful", "melange", "mumble", "Rebecca", "rklyne", "Rustler",
          "Sidra", "staranise", "Stowaway", "testy", "Tel", "tomatopudding",
          "zelempa", "zoemathemata", "Zooey_Glass", "zlabya",
]

# a bunch of bigger collections (>250 works)
# probably would be scooped up anyway, but just in case

COLLECTION_SEEDS = [
          "yuletide2009", "ladieschoice", "yuletidemadness2009", "female_focus",
          "crossgen_slash", "PornBattleIX", "Remix2010", "yuletide2010", "fic_promptly",
          "chromatic_yuletide_2010", "Fandom_Stocking", "yuletidemadness2010", "PornBattleXI",
          "Remix2011", "PornBattleXII",
]

# Note: every NTH user (randomized) will have all their associated records dumped
# many more than that users will be in the database, however because of associations
# This number is also used to limit the number of readings, comments, and feedbacks
# this number should increase as the archive grows to keep the decimated database a reasonable size
NTH = 200
# Every Mth work in a collection
MTH = 50

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

### start work (I know it's linear instead of object oriented. sue me. or fix it yourself) ###

FileUtils.mkdir_p(BACKUPDIR)
FileUtils.chdir(BACKUPDIR)

USERS = []
WORKS = []
PSEUDS = []
TAGS = []
COLLECTIONS = []

# the user is the starting point.
SEEDS.each do |seed|
  user = User.find_by_login(seed)
  raise "seed #{seed} is not a user!!!" unless user.is_a?(User)
  USERS << user
end
# add random Nth user
User.find_in_batches(:batch_size => NTH ) {|users| USERS << users.sample } if MULTI

# return an array of records associated with the users
# but keep the collections, works, pseuds and tags for later
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
      p.collections.each {|c| COLLECTIONS << c}
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
    end
  end
  x.flatten.compact.uniq
end

# dump the records associated with the USERS
puts ""
puts "Dumping records for #{USERS.compact.uniq.size} users (collecting COLLECTIONS, WORKS, PSEUDS & TAGS)"
user_associations(USERS.compact.uniq).each {|item| write_model(item)}

## Now deal with COLLECTIONS, WORKS, PSEUDS, and TAGS
## COLLECTIONS first because it add more WORKS

if MULTI
  COLLECTION_SEEDS.each do |seed|
    collection = Collection.find_by_name(seed)
    raise "seed #{collection} is not a collection!!!" unless collection.is_a?(Collection)
    COLLECTIONS << collection
  end
  COLLECTIONS.compact.each {|c| COLLECTIONS << c.parent }
end

# return an array of records associated with the collection
# but keep the works and pseuds for later
def collection_associations(items)
  puts " collecting collection associations"
  x = []
  items.each do |collection|
    puts " collecting #{collection.name}'s records"
    # dump the collection itself
    x << collection

    # add related works.
    # if the work is private or unrevealed it will get culled in the works_associations task
    if MULTI
      collection.works.find_in_batches(:batch_size => MTH ) {|work| WORKS << work }
    else
      # dunno if you should really get all the works in your collection, but we don't use the
      # non-MULTI version right now anyway so it doesn't really matter
      collection.works.each {|work| WORKS << work }
    end

    # add participants and their related pseuds
    x << collection.collection_participants
    collection.collection_participants.each {|participant| PSEUDS << participant.pseud }

    # add the rest of the associations
    x << collection.collection_profile
    x << collection.collection_preference
    x << collection.challenge
    x << collection.prompts
    x << collection.signups
    x << collection.assignments
    x << collection.claims
  end
  x.flatten.compact.uniq
end

# dump the records associated with the COLLECTIONS
puts ""
puts "Dumping records for #{COLLECTIONS.flatten.compact.uniq.size} collections (collecting WORKS & PSEUDS)"
collection_associations(COLLECTIONS.flatten.compact.uniq).each {|item| write_model(item)}

## Now deal with WORKS, PSEUDS, and TAGS
## WORKS next, because it adds more to PSEUDS and TAGS

# return an array of records associated with the works
# but keep the pseuds and tags for later
def work_associations(items)
  puts " collecting work associations"
  x = []
  items.each do |work|
    print "."; STDOUT.flush
    next unless (!work.unrevealed? && work.posted?) || !MULTI
    # dump the work itself
    x << work

    # add associations for the work and its chapters (keeping tags and pseuds for later)
    x << work.taggings
    work.tags.each { |t| TAGS << t }
    x << work.creatorships
    work.pseuds.each {|p| PSEUDS << p }
    x << work.language
    x << work.hit_counter
    x << work.gifts
    work.gifts.each {|g| PSEUDS << g.pseud }
    x << work.kudos
    work.kudos.each {|k| PSEUDS << k.pseud }
    x << work.serial_works
    x << work.series
    work.chapters.each do |c|
      x << c if c.posted? || !MULTI
      c.pseuds.each {|p| PSEUDS << p }
      x << c.comments
      c.comments.each { |c| PSEUDS << c.pseud }
      x << c.kudos
      c.kudos.each { |k| PSEUDS << k.pseud }
    end
  end
  x.flatten.compact.uniq
end

puts ""
puts "Dumping records for #{WORKS.flatten.compact.uniq.size} works (collecting PSEUDS & TAGS)"
work_associations(WORKS.flatten.compact.uniq).each {|item| write_model(item)}

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
puts "Dumping records for the associations for #{original_tags.size} tags (collecting PSEUDS)"
tag_assocations(original_tags).each {|item| write_model(item)}

new_tags = TAGS.flatten.compact.uniq - original_tags
puts ""
puts "Dumping records for the associations for #{new_tags.size} more tags (collecting PSEUDS)"
tag_assocations(new_tags).each {|item| write_model(item)}

more_tags = TAGS.flatten.compact.uniq - original_tags - new_tags
puts ""
puts "Dumping records for the associations for #{more_tags.size} more tags (collecting PSEUDS)"
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

# dump models not gathered elsewhere
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
