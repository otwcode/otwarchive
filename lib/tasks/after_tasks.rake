namespace :After do

  ##################################################################
  # LEAVE THIS SECTION ALONE -- turns off TS deltas and turns them back on
  # after all migrate tasks are run
#  desc "Turn off thinking sphinx deltas"
#  task(:turn_off_deltas => :environment) do
#    puts "Disabling Thinking Sphinx updates while we migrate..."
#    ThinkingSphinx.deltas_enabled=false
#    puts %x{script/delayed_job stop}
#  end
#
#  desc "Turn on thinking sphinx deltas"
#  task(:turn_on_deltas => :environment) do
#    ThinkingSphinx.deltas_enabled=true
#    puts "Re-enabled Thinking Sphinx updates"
#    puts %x{script/delayed_job start}
#  end
#
#  # top_level_tasks isn't writable so we need to do this
#  # instance_variable_set hack to prepend/append the delta
#  # tasks when the After tasks are run
#  current_tasks =  Rake.application.top_level_tasks
#  if current_tasks.first && current_tasks.first.match(/After/)
#    current_tasks.unshift('After:turn_off_deltas')
#    current_tasks << 'After:turn_on_deltas'
#    Rake.application.instance_variable_set(:@top_level_tasks, current_tasks)
#  end
  ###################################################################


# everything commented out has already been run on the archive...
# keeping only the most recent tasks - if you need to go back further, check subversion

#  desc "Fix warning tags"
#  task(:fix_warnings => :environment) do
#    good_tag = Warning.find_by_name("Rape/Non-Con")
#    bad_tag = Warning.find_by_name("Rape/Non Con")
#    if good_tag && bad_tag
#      # First make them synonyms so that the works get the good tag as a filter
#      bad_tag.merger = good_tag
#      bad_tag.save!
#      # Then just move all the taggings to the right tag
#      Tagging.update_all("tagger_id = #{good_tag.id}", "tagger_id = #{bad_tag.id}")
#      bad_tag.reload
#      if bad_tag.taggings.count == 0
#        bad_tag.destroy
#      else
#        raise "Something went wrong with the warning tags"
#      end
#    end
#    violence_tag = Warning.find_by_name(ArchiveConfig.WARNING_VIOLENCE_TAG_NAME)
#    if violence_tag && violence_tag.name != ArchiveConfig.WARNING_VIOLENCE_TAG_NAME
#      violence_tag.update_attribute(:name, ArchiveConfig.WARNING_VIOLENCE_TAG_NAME)
#    end
#  end
#
#  desc "Clear up wrangling relationships"
#  task(:tidy_wranglings => :environment) do
#    [Character, Relationship, Freeform].each do |klass|
#      puts "Updating #{klass.to_s.downcase.pluralize}"
#      klass.by_name.find(:all, :conditions => "fandom_id IS NOT NULL").each do |tag|
#        begin
#          puts tag.name
#          if tag.fandom && !tag.fandoms.include?(tag.fandom)
#            tag.fandoms << tag.fandom
#          end
#        rescue
#          puts "Something went wrong with #{tag.name}!"
#        end
#      end
#    end
#    Fandom.by_name.each do |tag|
#      begin
#        puts tag.name
#        if tag.media_id && tag.media && !tag.medias.include?(tag.media)
#          tag.parents << tag.media
#        end
#        if tag.medias.empty?
#          tag.parents << Media.uncategorized
#        end
#      rescue
#        puts "Something went wrong with #{tag.name}!"
#      end
#    end
#  end
#
#  desc "Remove invalid synonyms from canonical tags"
#  task(:exorcise_syns => :environment) do
#    tags = Tag.canonical.find(:all, :conditions => "merger_id IS NOT NULL")
#    tags.each { |tag| tag.update_attribute(:merger_id, nil) }
#  end
#
#  desc "Clean up invites belonging to deleted users"
#  task(:deleted_invites_cleanup => :environment) do
#    UserInviteRequest.all.each do |user_invite_request|
#      if user_invite_request.user.nil?
#        user_invite_request.destroy
#      end
#    end
#  end
#
# desc "Map gifts to pseuds where that is feasible"
# task(:map_gifts => :environment) do
#   gifts = Gift.find(:all)
#   gifts.each do |gift|
#     puts "Setting recipient for gift to #{gift.recipient_name}"
#     gift.recipient = gift.recipient_name
#     gift.save
#   end
# end
#
# desc "Clean up related works that are connected to deleted works"
# task(:related_work_cleanup => :environment) do
#   RelatedWork.all.each do |rw|
#     unless rw.parent && rw.work
#       rw.destroy
#     end
#   end
# end
#

#  desc "Make reading count 1 instead of 0 for existing readings"
#  task(:reading_count_setup => :environment) do
#    Reading.update_all("view_count = 1", "view_count = 0")
#  end

#  desc "Move hit counts to their own table"
#  task(:move_hit_counts => :environment) do
#    Work.find_each do |work|
#      counter = work.build_hit_counter(:hit_count => work.hit_count_old, :last_visitor => work.last_visitor_old)
#      counter.save
#    end
#  end

#  desc "Add skins"
#  task(:add_skins => :environment) do
#    default = Skin.create_default
#    plain = Skin.import_plain_text
#    Preference.update_all("skin_id = #{default.id}")
#    Preference.update_all("skin_id = #{plain.id}", "plain_text_skin = 1")
#  end

#  desc "Rename Pairing tag type to Relationship"
#  task(:rename_pairing => :environment) do
#    Tag.update_all("type = 'Relationship'", "type = 'Pairing'")
#  end

#  desc "Set meta filter taggings to inherited"
#  task(:mark_meta_tags_inherited => :environment) do
#    Tag.canonical.meta_tag.find_each do |meta_tag|
#      puts "Meta tag: #{meta_tag.id}"
#      meta_tag.filter_taggings.update_all("inherited = 1")
#      filter_ids = [meta_tag.id] + meta_tag.mergers.map{|m| m.id}
#      # filter taggings that originated with the meta tag or one of its mergers
#      # should not be marked inherited
#      fts = FilterTagging.joins("LEFT JOIN taggings ON
#                                taggings.taggable_id = filter_taggings.filterable_id").
#                          where(["filter_taggings.filter_id = ? AND
#                                taggings.taggable_type = 'Work' AND
#                                filter_taggings.filterable_type = 'Work' AND
#                                taggings.id IS NOT NULL AND
#                                taggings.tagger_id IN (?)",
#                                meta_tag.id, filter_ids])
#      unless fts.blank?
#        FilterTagging.update_all("inherited = 0", ["id IN (?)", fts.map{|ft| ft.id}])
#      end
#    end
#  end

#  desc "fix old '- Pairing' names"
#  task(:update_pairing_names => :environment) do
#    tags = Relationship.where('name LIKE ?', "% - Pairing")
#    tags.each do |t|
#      oldname = t.name
#      newname = oldname.gsub(/ - Pairing$/, " - Relationship")
#      begin
#        t.update_attribute(:name, newname)
#      rescue ActiveRecord::RecordNotUnique
#        puts "\"#{oldname}\" couldn't be renamed because \"#{newname}\" already exists"
#      end
#    end
#  end


#  desc "Clear out old epub files"
#  task(:remove_old_epubs => :environment) do
#    download_dir =  "#{Rails.public_path}/downloads/"
#    cmd = %Q{find #{download_dir} -depth -name epub -exec rm -rf {} \\;}
#    puts cmd
#    `#{cmd}`
#    cmd = %Q{find #{download_dir} -name "*.epub" -exec rm {} \\;}
#    puts cmd
#    `#{cmd}`
#  end

#  desc "update filter taggings since nov 21"
#  task(:update_filter_taggings => :environment) do
#    Tag.where("updated_at > ?", "2010-11-21").where("canonical = 1 OR merger_id IS NOT NULL").where("taggings_count != 0").each do |tag|
#      tag.add_filter_taggings
#    end
#  end

#  desc "Create work skin"
#  task(:add_skins => :environment) do
#    default = WorkSkin.basic_formatting
#    default ? puts("Basic work skin") : puts("Check work skin!")
#  end

#  desc "Fix default pseuds"
#  task(:fix_default_pseuds => :environment) do
#    puts "Fixing default pseuds"
#    # for every user who doesn't have a pseud marked is_default
#    (User.all - (User.joins(:pseuds) & Pseud.where(:is_default => true))).each do |user|
#      if user.pseuds.first
#        # find the old default pseud and actually mark it default
#        user.pseuds.first.update_attribute(:is_default, true)
#      else
#        # create a new default pseud with the same name as the login
#        user.pseuds << Pseud.new(:name => user.login, :is_default => true)
#        puts "created pseud for #{user.login}"
#      end
#    end
#  end
#
#  desc "Remove owner kudos"
#  task(:remove_owner_kudos => :environment) do
#    puts "Removing owner kudos"
#    Kudo.with_pseud.each do |kudo|
#      if kudo.commentable.blank?
#        puts "the following kudo has no commentable!"
#        p kudo
#      elsif kudo.commentable.pseuds.include?(kudo.pseud)
#        puts "the following kudo was destroyed"
#        p kudo
#        kudo.destroy
#      end
#    end
#  end
# 
# desc "Fix works without posted chapters"
# task(:post_chapters => :environment) do
#   Chapter.joins(:work).
#           where("works.posted = 1 AND chapters.posted = 0 AND chapters.position = 1").
#           readonly(false).each do |c|
#     if c.work.chapters.posted.count == 0
#       c.update_attribute(:posted, true)
#     end
#   end
# end


  #### Leave this one here

  desc "Update the translation file each time we deploy"
  task(:update_translations => :environment) do
    tg = TranslationGenerator.new
    tg.generate_default_translation_file
  end

  #### Add your new tasks here

  desc "Move kudos to works instead of chapters"
  task(:move_kudos_to_works => :environment) do
    Chapter.joins(:kudos).group("chapters.id").find_each do |chapter|
      puts chapter.id
      chapter.kudos.update_all("commentable_id = #{chapter.work_id}, commentable_type = 'Work'")
    end
  end

end # this is the end that you have to put new tasks above

##################
# ADD NEW MIGRATE TASKS TO THIS LIST ONCE THEY ARE WORKING

# Remove tasks from the list once they've been run on the deployed site
desc "Run all current migrate tasks"
#task :After => ['After:fix_default_pseuds', 'After:remove_owner_kudos']
task :After => ['After:move_kudos_to_works']
