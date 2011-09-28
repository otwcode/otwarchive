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
          "elz", "erda", "Enigel", "Hope", "Jaetion", "justira", "jetta_e_rus",
          "lim", "Lisztful", "melange", "mumble", "Rebecca", "RKlyne", "Rustler",
          "Sidra", "staranise", "Stowaway", "testy", "Tel", "tomatopudding",
          "xparrot", "zelempa", "zoemathemata", "Zooey_Glass", "zlabya",
]

# seeds who want their email address preserved for testing
EMAIL = [ "admin-amelia", "admin-elz", "admin-emilie", "admin-franny",
          "admin-kielix", "admin-shalott", "admin-sidra",
          "astolat", "aworldinside", "bingeling", "cesy", "cesytest", "elz",
          "Enigel", "mumble", "Sidra", "testy", "xparrot", "Zooey_Glass" ]

# a bunch of bigger collections (>250 works)
# probably would be scooped up anyway, but just in case

COLLECTION_SEEDS = [
          "yuletide2009", "ladieschoice", "yuletidemadness2009", "female_focus",
          "crossgen_slash", "PornBattleIX", "Remix2010", "yuletide2010", "fic_promptly",
          "chromatic_yuletide_2010", "Fandom_Stocking", "yuletidemadness2010", "PornBattleXI",
          "Remix2011", "PornBattleXII",
]

# N determines how many users, works, bookmarks, etc. are dumped if they aren't all dumped
N = 15

# private bookmarks and unpublished works are not selected in a multi-user dump
MULTI = true

## WARNING. haven't tested single user dumps lately. probably doesn't work
## to dump just one user uncomment the following and replace the user name
## (you can either comment out the previous ones, or just ignore the already initialized warning)

#   SEEDS = [ "Sidra" ]
#   N = 1
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
  raise "#{thing} is not a model!!!" if thing.is_a?(Array)
  raise "#{thing} is not a model!!!" unless thing
  file = thing.class.name.underscore + ".sql"
  # print out something (small) so we know things are happening
  initial = file.first
  print initial; STDOUT.flush

  # redact email addresses
  if thing.respond_to? :email
    if thing.respond_to? :login  # users and admins
      thing.email = "#{thing.login}-seed@ao3.org" unless EMAIL.include?(thing.login)
    else # everything else
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

USERS = {}
COLLECTIONS = {}
WORKS = {}
PSEUDS = {}
TAGS = {}

# populate the hashes
SEEDS.each do |seed|
  user = User.find_by_login(seed)
  raise "seed #{seed} is not a user!!!" unless user.is_a?(User)
  USERS[user.id] = user
end
# add all the tag wranglers
Role.find_by_name("tag_wrangler").users.each { |u| USERS[u.id] = u }

# add N extra random users
User.find_in_batches(:batch_size => User.count/N ) do |users|
  user = users.sample
  USERS[user.id] = user
end if MULTI

# add unwrangled TAGS
Tag.unwrangled.each do |t|
  TAGS[t.id] = t
  # and a few works
  t.works.limit(5).each {|w| WORKS[w.id] = w}
end

# Start dumping!

# dump models not in the above five classes
if MULTI
  # admin posts
  puts ""
  puts "Dumping admin posts (collecting PSEUDS)"
  AdminPost.find_each do |p|
    write_model(p)
    p.comments.each { |c| PSEUDS[c.pseud.id] = c.pseud if c.pseud}
  end
  # roles are associated with users, but we need them all
  puts ""
  puts "Dumping roles"
  Role.find_each {|r| write_model(r)}
  puts ""
  puts "Dumping all admins"
  Admin.find_each {|a| write_model(a)}
  puts ""
  puts "Dumping admin settings"
  write_model(AdminSetting.first)
  puts ""
  puts "Dumping official skins"
  Skin.where(:official => true).each{|s| write_model(s)}
  puts ""
  puts "Dumping FAQs"
  ArchiveFaq.find_each {|f| write_model(f)}
  puts ""
  puts "Dumping Known Issues"
  KnownIssue.find_each {|ki| write_model(ki)}
  puts ""
  puts "Dumping every #{N} feedback"
  Feedback.find_in_batches(:batch_size => N ) {|b| write_model(b.last)}
end

# dump models from USERS, COLLECTIONS, WORKS, TAGS & PSEUDS
# each one has a specific method, which is then called with the hash

# return an array of records associated with the users
# but keep the collections, works, pseuds and tags for later
def user_associations(users)
  users.each_value do |u|
    puts ""
    puts " #{u.login}'s records"

    ## PSEUDS will dump the actual user record and the user's preferences
    ## so they don't need to be dumped here.
    u.pseuds.each { |p| PSEUDS[p.id] = p }

    # the roles are all dumped separately, so just dump the associations here
    u.roles_users.each { |x| write_model(x) }

    write_model(u.profile) unless MULTI   # profile's may have sensitive information that isn't visible

    if u.is_tag_wrangler?
      u.fandoms.each { |t| TAGS[t.id] = t }
      u.wrangling_assignments.each { |x| write_model(x) }
    end

    u.skins.each { |x| write_model(x) }
    u.invitations.each { |x| write_model(x) }

    # get some readings to read, and some read
    u.readings.where(:toread => true).find_in_batches(:batch_size => u.readings.size/N/2 + 1) do |readings|
      reading = readings.sample
      write_model(reading)
      WORKS[reading.work.id] = reading.work if reading.work && MULTI
    end
    u.readings.where(:toread => false).find_in_batches(:batch_size => u.readings.size/N/2 + 1) do |readings|
      reading = readings.sample
      write_model(reading)
      WORKS[reading.work.id] = reading.work if reading.work && MULTI
    end

    # comments need associations
    u.inbox_comments.find_in_batches(:batch_size => u.inbox_comments.size/N + 1) do |batch|
      inbox_comment = batch.sample
      write_model(inbox_comment)
      write_model(inbox_comment.feedback_comment)
      commentable = inbox_comment.feedback_comment.ultimate_parent
      if MULTI
        if commentable.is_a?(Work)
          WORKS[commentable.id] = commentable
        elsif commentable.is_a?(Tag)
          TAGS[commentable.id] = commentable
        else
          write_model(commentable)
        end
      end
      PSEUDS[inbox_comment.feedback_comment.pseud.id] = inbox_comment.feedback_comment.pseud if inbox_comment.feedback_comment.pseud
      commentable = inbox_comment.feedback_comment.ultimate_parent
      WORKS[commentable.id] = commentable if (MULTI && commentable.is_a?(Work))
    end

    u.subscriptions.find_in_batches(:batch_size => u.subscriptions.size/N + 1) do |subscriptions|
      subscription = subscriptions.sample
      write_model(subscription)
      subscription.subscribable.pseuds.each {|p| PSEUDS[p.id] = p } if subscription.subscribable.is_a?(User)
    end

    # most of the associations are actually through the pseuds
    u.pseuds.each do |p|
      p.collections.find_in_batches(:batch_size => p.collections.size/5 + 1) do |collections|
        collection = collections.sample
        COLLECTIONS[collection.id] = collection
        COLLECTIONS[collection.parent.id] = collection.parent if collection.parent
      end
      p.comments.find_in_batches(:batch_size => N) do |comments|
        comment = comments.sample
        write_model(comment)
        if MULTI
          commentable = comment.ultimate_parent
          if commentable.is_a?(Work)
            WORKS[commentable.id] = commentable
          elsif commentable.is_a?(Tag)
            TAGS[commentable.id] = commentable
          elsif commentable
            write_model(commentable)
          end
        end
      end
      p.bookmarks.find_in_batches(:batch_size => p.bookmarks.size/N + 1) do |bookmarks|
        bookmark = bookmarks.sample
        if !bookmark.private? || !MULTI
          write_model(bookmark)
          bookmark.taggings.each { |x| write_model(x) }
          bookmark.tags.each { |t| TAGS[t.id] = t }
          if MULTI
            bookmarkable = bookmark.bookmarkable
            if bookmarkable.is_a?(Work)
              WORKS[bookmarkable.id] = bookmarkable
            elsif bookmarkable.is_a?(Series)
              write_model(bookmarkable)
              bookmarkable.works.each {|w| WORKS[w.id] = w}
            elsif bookmarkable.is_a?(ExternalWork)
              write_model(bookmarkable)
              bookmarkable.taggings.each { |x| write_model(x) }
              bookmarkable.tags.each { |t| TAGS[t.id] = t }
            end
          end
        end
      end

      p.creatorships.where(:creation_type => 'Work').find_in_batches(:batch_size => p.works.size/N + 1) do |creatorships|
        work = creatorships.sample.creation
        if work && (work.posted? || !MULTI)
          WORKS[work.id] = work
          work.related_works.each { |x| write_model(x) }
          work.related_works.each { |r| WORKS[r.work.id] = r.work }
        end
      end
    end
  end
end

# dump the records associated with the USERS
puts ""
puts "Dumping records for #{USERS.size} users (collecting COLLECTIONS, WORKS, PSEUDS & TAGS)"
user_associations(USERS)

## Now deal with COLLECTIONS, WORKS, PSEUDS, and TAGS
## COLLECTIONS first because it add more WORKS

if MULTI
  COLLECTION_SEEDS.each do |seed|
    collection = Collection.find_by_name(seed)
    raise "seed #{collection} is not a collection!!!" unless collection.is_a?(Collection)
    COLLECTIONS[collection.id] = collection
  end
end

# return an array of records associated with the collection
# but keep the works and pseuds for later
def collection_associations(items)
  items.each_value do |collection|
    puts ""
    puts " #{collection.name}'s records"
    # dump the collection itself
    write_model(collection)

    # add related works.
    # if the work is private or unrevealed it will get culled in the works_associations task
    if MULTI
      collection.collection_items.find_in_batches(:batch_size => collection.collection_items.size/N + 1 ) do |items|
        item = items.sample
        write_model(item)
        work = item.work
        WORKS[work.id] = work
      end
    else
      # dunno if you should really get all the works in your collection, but we don't use the
      # non-MULTI version right now anyway so it doesn't really matter
      collection.works.each {|w| WORKS[w.id] = w }
    end

    # add participants and their related pseuds
    collection.collection_participants.each {|x| write_model(x)}
    collection.collection_participants.each {|p| PSEUDS[p.pseud.id] = p.pseud if p.pseud }

    # add the rest of the associations
    write_model(collection.collection_profile)
    write_model(collection.collection_preference)
    collection.prompts.each {|x| write_model(x)}
    collection.signups.each {|x| write_model(x)}
    collection.assignments.each {|x| write_model(x)}
    collection.claims.each {|x| write_model(x)}

    # challenge associations
    c = collection.challenge
    if c
      write_model(c)
      write_model(c.request_restriction)
    end

  end
end

# dump the records associated with the COLLECTIONS
puts ""
puts "Dumping records for #{COLLECTIONS.size} collections (collecting WORKS & PSEUDS)"
collection_associations(COLLECTIONS)

## Now deal with WORKS, PSEUDS, and TAGS
## WORKS next, because it adds more to PSEUDS and TAGS

# return an array of records associated with the works
# but keep the pseuds and tags for later
def work_associations(items)
  items.each_value do |work|
    next unless (!work.unrevealed? && work.posted?) || !MULTI
    # dump the work itself
    puts ""
    write_model(work)

    # add associations for the work and its chapters (keeping tags and pseuds for later)
    work.creatorships.each {|x| write_model(x)}
    work.pseuds.each {|p| PSEUDS[p.id] = p }
    write_model(work.language) if work.language
    write_model(work.hit_counter)
    work.gifts.each {|x| write_model(x)}
    work.gifts.each {|g| PSEUDS[g.pseud.id] = g.pseud if g.pseud}
    work.serial_works.each {|x| write_model(x)}
    work.series.each {|x| write_model(x)}

    work.taggings.each {|x| write_model(x)}
    work.tags.each { |t| TAGS[t.id] = t }
    work.kudos.each {|x| write_model(x)}
    work.kudos.each {|k| PSEUDS[k.pseud.id] = k.pseud if k.pseud}

    work.chapters.each do |c|
      if c.posted? || !MULTI
        write_model(c)
        c.creatorships.each {|x| write_model(x)}
      end
      c.pseuds.each {|p| PSEUDS[p.id] = p }
      c.comments.each {|x| write_model(x)}
      c.comments.each { |c| PSEUDS[c.pseud.id] = c.pseud if c.pseud }
      c.kudos.each {|x| write_model(x)}
      c.kudos.each { |k| PSEUDS[k.pseud.id] = k.pseud if k.pseud}
    end
  end
end

puts ""
puts "Dumping records for #{WORKS.size} works (collecting PSEUDS & TAGS)"
work_associations(WORKS)

# return an array of records associated with the tags
def tag_associations(tags)
  new_tags = {}
  tags.each_value do |t|
    write_model(t)
    if t.last_wrangler.is_a? User
      t.last_wrangler.pseuds.each { |p| PSEUDS[p.id] = p }
    end
    new_tags[t.merger.id] = t.merger if t.merger && !tags[t.merger.id]
    t.common_taggings.each {|x| write_model(x)}
    t.parents.each {|t| new_tags[t.id] = t unless tags[t.id]}
    t.meta_taggings.each {|x| write_model(x)}
    t.meta_tags.each {|t| new_tags[t.id] = t unless tags[t.id]}
    t.comments.each {|x| write_model(x)}
    t.comments.each { |c| PSEUDS[c.pseud.id] = c.pseud if c.pseud }
  end
  new_tags
end

original_tags = TAGS
4.times do |i|
  puts ""
  puts "#{i}: Dumping records for the associations for #{original_tags.size} tags (collecting PSEUDS and more TAGS)"
  original_tags = tag_associations(original_tags)
end

# return an array of records associated with the pseuds
def pseud_associations(pseuds)
  pseuds.each_value do |p|
    write_model(p)
    write_model(p.user)
    write_model(p.user.preference)
  end
end

puts ""
puts "Dumping records for #{PSEUDS.size} pseuds"
pseud_associations(PSEUDS)

puts ""
puts "Done!"
