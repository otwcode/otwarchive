namespace :After do

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
#      counter = work.build_stat_counter(:hit_count => work.hit_count_old, :last_visitor => work.last_visitor_old)
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

# desc "Clear out old epub files"
# task(:remove_old_epubs => :environment) do
#   download_dir = Rails.public_path.join("downloads").to_s
#     cmd = %Q{find #{download_dir} -depth -name epub -exec rm -rf {} \\;}
#     puts cmd
#     `#{cmd}`
#  cmd = %Q{find #{download_dir} -name "*.epub" -exec rm {} \\;}
#  puts cmd
#  `#{cmd}`
# end

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

#  desc "Move kudos to works instead of chapters"
#  task(:move_kudos_to_works => :environment) do
#    Chapter.joins(:kudos).group("chapters.id").find_each do |chapter|
#      puts chapter.id
#      chapter.kudos.update_all("commentable_id = #{chapter.work_id}, commentable_type = 'Work'")
#    end
#  end
#
#  desc "Set restricted to false instead of null"
#  task(:fix_restricted => :environment) do
#    Work.where("restricted IS NULL").update_all(:restricted => false)
#  end



#  desc "Set complete status for works"
#  task(:set_complete_status => :environment) do
#    Work.update_all("complete = 1", "expected_number_of_chapters = 1")
#    Work.find_each(:conditions => "expected_number_of_chapters > 1") do |w|
#      puts w.id
#      if w.chapters.posted.count == w.expected_number_of_chapters
#        Work.update_all("complete = 1", "id = #{w.id}")
#      end
#    end
#  end

#  desc "Send out external author invitations that got missed"
#  task(:invite_external_authors => :environment) do
#    Invitation.where("sent_at is NULL").where("external_author_id IS NOT NULL").each do |invite|
#      archivist = invite.external_author.external_creatorships.collect(&:archivist).collect(&:login).uniq.join(", ")
#      UserMailer.invitation_to_claim(invite, archivist).deliver_now
#      invite.sent_at = Time.now
#      invite.save
#    end
#  end

# desc "Convert existing prompt restriction tag sets to owned tag sets"
# task(:convert_tag_sets => :environment) do
#   GiftExchange.includes(:prompt_restriction, :request_restriction, :offer_restriction).find_each do |exchange|
#     unless exchange.collection
#       puts "No collection for gift exchange #{exchange.id}!"
#       next
#     end
#     owners = exchange.collection.all_owners
#     title = exchange.collection.title
#     convert_restriction_tagset(exchange.prompt_restriction, owners, title + "_prompts")
#     convert_restriction_tagset(exchange.request_restriction, owners, title + "_requests")
#     convert_restriction_tagset(exchange.offer_restriction, owners, title + "_offers")
#   end
#   PromptMeme.includes(:request_restriction).find_each do |meme|
#     unless meme.collection
#       puts "No collection for prompt meme #{meme.id}!"
#       next
#     end
#     owners = meme.collection.all_owners
#     title = meme.collection.title
#     convert_restriction_tagset(meme.prompt_restriction, owners, title + "_prompts")
#     convert_restriction_tagset(meme.request_restriction, owners, title + "_requests")
#   end
# end
#
# def convert_restriction_tagset(restriction, owner_pseuds, title)
#   if restriction && restriction.tag_set_id
#     tag_set_title = "Tag Set For #{title.gsub(/[^\w\s]+/, '_')}"
#     ots = OwnedTagSet.new(:tag_set_id => restriction.tag_set_id, :title => tag_set_title)
#     # make all the owners of the collection the owners of the tag set
#     owner_pseuds.each {|owner| ots.add_owner(owner)}
#     if ots.save
#       restriction.owned_tag_sets << ots
#       restriction.tag_set_id = nil
#       restriction.save
#     else
#       puts "Couldn't convert #{tag_set_title}: #{ots.errors.to_s}"
#     end
#   end
# end
#
# desc "Convert existing skins to be based off version 1.0"
# task(:convert_existing_skins => :environment) do
#   oldskin = Skin.find_by_title_and_official("Archive 1.0", true)
#   unless oldskin
#     puts "WARNING: couldn't convert skins, version 1.0 skin not found: did you load the site skins?"
#     exit
#   end
#   Skin.site_skins.each do |skin|
#     next if skin.css.blank? || !skin.parent_skins.empty?
#     skin.role = "override"
#     if skin.save
#       skin.skin_parents.build(:position => (skin.parent_skins.count+1), :parent_skin => oldskin)
#       skin.save
#     else
#       puts "Couldn't convert #{skin.title}: #{skin.errors.to_s} - disabling"
#       if skin.official?
#         skin.update_attribute(:official, false)
#         skin.remove_me_from_preferences
#       end
#     end
#   end
# end
#
#
# require 'nokogiri'
#
# desc "Esacape ampersands in work titles"
# task(:escape_ampersands => :environment) do
#   Work.where("title LIKE '%&%'").each do |work|
#     work.title = Nokogiri::HTML.fragment(work.title).to_s
#     work.save
#   end
# end
#
# desc "Set stat counts for works"
# task(:set_work_stats => :environment) do
#   Work.find_each do |work|
#     puts work.id
#     work.update_stat_counter
#   end
# end
#
# desc "Set anon/unrevealed status for works"
# task(:set_anon_unrevealed => :environment) do
#   CollectionItem.where("(anonymous = 1 OR unrevealed = 1) AND item_type = 'Work'").each do |collection_item|
#     puts collection_item.id
#     work = collection_item.item
#     if work.present?
#       work.update_attributes(
#         in_anon_collection: collection_item.anonymous,
#         in_unrevealed_collection: collection_item.unrevealed
#       )
#     end
#   end
# end
#
# desc "Add filters to external works"
# task(:external_work_filters => :environment) do
#   ExternalWork.find_each do |ew|
#     puts ew.id
#     ew.check_filter_taggings
#   end
# end

  #### Add your new tasks here

  desc "Set initial values for sortable tag names"
  task(:sortable_tag_names => :environment) do
    Media.all.each{ |m| m.save }

    Fandom.find_each do |fandom|
      fandom.set_sortable_name
      puts fandom.sortable_name
      fandom.save
    end
  end

  desc "Increase skins' width threshold for handheld devices to 640px"
  task(:increase_handheld_width => :environment) do
    hh_width_media = "only screen and (max-width: 480px)"
    hh_skins = Skin.select { |s| s.media.include? hh_width_media }
    hh_skins.each do |skin|
      new_media = skin.media.map { |m| m == hh_width_media ? "only screen and (max-width: 640px)" : m }
      skin.media = new_media
      skin.save
    end
  end

  desc "Set up available locales"
  task(:locale_setup => :environment) do
    I18n.available_locales.each do |iso|
      next if Locale.where(iso: iso).exists?
      iso = iso.to_s
      short = iso.split('-').first
      lang = Language.find_by_short(short)
      if lang.present?
        Locale.create(
          iso: iso,
          short: short,
          name: lang.name,
          language_id: lang.id
        )
      else
        puts "No language found for #{short}"
      end
    end
  end

  desc "Set initial values for sortable tag names for tags that aren't fandoms"
  task(:more_sortable_tag_names => :environment) do
    [Category, Character, Freeform, Rating, Relationship, ArchiveWarning].each do |klass|
      puts "Adding sortable names for #{klass.to_s.downcase.pluralize}"
      klass.by_name.find_each(:conditions => "canonical = 1 AND sortable_name = ''") do |tag|
        tag.set_sortable_name
        puts tag.sortable_name
        tag.save
      end
    end
  end

  desc "Clean up challenge_id and challenge_type in Collections with deleted Challenges"
  task(:remove_old_challenge_variables_from_collections => :environment) do
    Collection.find_each do |collection|
      unless collection.challenge?
        if collection.challenge_id.present? || collection.challenge_type.present?
          puts "Fixing collection: #{collection.name}"
          puts "Which is a #{collection}"
          collection.update_column(:challenge_id, nil)
          collection.update_column(:challenge_type, nil)
        end
      end
    end
  end


  desc "Clean up URLs for abuse reports from the last month"
  task(:clean_abuse_report_urls => :environment) do
    AbuseReport.where("created_at > ?", 1.month.ago).each do |report|
      report.clean_url
      puts report.url
      report.save
    end
  end

  desc "Change handheld skins to narrow skins with a max-width of 44em"
  task(:handheld_skin_to_narrow => :environment) do
    current_width_media = "only screen and (max-width: 640px)"
    skins_to_change = Skin.select { |s| s.media.include? current_width_media }
    skins_to_change.each do |skin|
      new_media = skin.media.map { |m| m == current_width_media ? "only screen and (max-width: 42em)" : m }
      skin.media = new_media
      skin.save
    end
  end

  desc "Generate custom CSS so people using an old wizard skin don't lose it"
  task(:generate_css_for_old_wizard_skins => :environment) do
    Skin.wizard_site_skins.each do |skin|
      old_css = skin.css.present? ? skin.css : ""

      wizard_css = ""

      if skin.margin.present?
        wizard_css += "#workskin {margin: auto #{skin.margin}%; padding: 0.5em #{skin.margin}% 0;} "
      end

      if skin.background_color.present? || skin.foreground_color.present? || skin.font.present? || skin.base_em.present?
        wizard_css += "body, #main {
          #{skin.background_color.present? ? "background: #{skin.background_color}; " : ''}
          #{skin.foreground_color.present? ? "color: #{skin.foreground_color}; " : ''} "
        if skin.base_em.present?
          wizard_css += "font-size: #{skin.base_em}%; line-height: 1.125; "
        end
        if skin.font.present?
          wizard_css += "font-family: #{skin.font}; "
        end
        wizard_css += "} "
      end

      if skin.paragraph_margin.present?
        wizard_css += ".userstuff p {margin-bottom: #{skin.paragraph_margin}em;} "
      end

      if skin.headercolor.present?
        wizard_css += "#header .main a, #header .main input, #header .search input {border-color: transparent;} "
        wizard_css += "#header, #header ul.main, #footer {background: #{skin.headercolor}; border-color: #{skin.headercolor}; box-shadow: none;} "
      end

      if skin.accent_color.present?
        wizard_css += "#header .icon, #dashboard ul, #main dl.meta {background: #{skin.accent_color}; border-color: #{skin.accent_color};} "
      end

      wizard_css += "#workskin {margin: auto #{skin.margin}%; padding: 0.5em #{skin.margin}% 0;} " if skin.margin.present?

      # clear out the wizard settings, prepend the wizard css to the user's custom css, and save
      unless wizard_css.blank?
        skin.margin, skin.background_color, skin.foreground_color, skin.font, skin.base_em, skin.paragraph_margin, skin.headercolor, skin.accent_color = nil
        skin.css = wizard_css + old_css
        skin.save
      end
    end
  end

  desc "Fix comment threaded_left and threaded_right."
  task(fix_comment_threading: :environment) do
    progress = 0

    # It's possible that the callback to fix threaded_left and threaded_right
    # after a comment is destroyed hasn't been working for some time. If so,
    # this task can be used to recalculate threaded_left and threaded_right for
    # all of the comments that need it.
    Comment.where("thread = id").includes(:thread_comments).find_each do |root|
      print "." and STDOUT.flush if ((progress += 1) % 1000).zero?

      # It only affects threads that have more than one comment.
      next if root.children_count.zero?

      # Get all threaded_left and threaded_right values.
      left_and_right_values = root.thread_comments.flat_map do |c|
        [c.threaded_left, c.threaded_right]
      end

      # Compute a mapping from threaded_left and threaded_right values
      # back to a compact version.
      left_and_right_values.sort!
      compact_left_and_right = {}
      left_and_right_values.each_with_index do |value, index|
        compact_left_and_right[value] = index + 1
      end

      # Calculate the changes that need to be made.
      changes = {}
      root.thread_comments.each do |c|
        new_left = compact_left_and_right[c.threaded_left]
        new_right = compact_left_and_right[c.threaded_right]
        if new_left != c.threaded_left || new_right != c.threaded_right
          changes[c.id] = { threaded_left: new_left, threaded_right: new_right }
        end
      end

      # Don't bother if we have nothing to change.
      next if changes.empty?

      Comment.transaction do
        changes.each_pair do |id, values|
          # Use update_all to bypass validations & callbacks (for speed).
          Comment.where(id: id).update_all(values)
        end
      end
    end

    print "\n"
  end

  desc "Prune unnecessary deleted comment placeholders."
  task(prune_deleted_comment_placeholders: :environment) do
    # This should be performed after the fix_comment_threading task, if that's
    # necessary. (It can be used without it, but unless threaded_left and
    # threaded_right are set correctly, it won't delete any existing
    # placeholders.)
    Comment.where(is_deleted: true).find_each do |placeholder|
      if placeholder.children_count.zero?
        # We don't need a placeholder if it doesn't have children.
        placeholder.destroy
      end
    end
  end

  desc "Enforce HTTPS where available for embedded media"
  task(enforce_https: :environment) do
    Chapter.find_each do |chapter|
      if chapter.id % 1000 == 0
        puts chapter.id
      end
      if chapter.content.match /<(embed|iframe)/
        begin
          chapter.content_sanitizer_version = -1
          chapter.sanitize_field(chapter, :content)
        rescue
          puts "couldn't update chapter #{chapter.id}"
        end
      end
    end
  end

  desc "Enforce HTTPS where available for embedded media from ning.com and vidders.net"
  task(enforce_https_viddersnet: :environment) do
    Chapter.find_each do |chapter|
      puts chapter.id if (chapter.id % 1000).zero?
      if chapter.content.match /<(embed|iframe) .*(ning\.com|vidders\.net)/
        begin
          chapter.content_sanitizer_version = -1
          chapter.sanitize_field(chapter, :content)
        rescue StandardError
          puts "couldn't update chapter #{chapter.id}"
        end
      end
    end
  end

  desc "Fix crossover status for works with two fandom tags."
  task(crossover_reindex_works_with_two_fandoms: :environment) do
    # Find all works with two fandom tags:
    Work.joins(:tags).merge(Fandom.all).
      group("works.id").having("COUNT(tags.id) > 1").
      select(:id).
      find_in_batches do |batch|
      print(".") && STDOUT.flush
      AsyncIndexer.index(WorkIndexer, batch.map(&:id), :background)
    end
    print("\n") && STDOUT.flush
  end

  # Usage: rake After:reset_word_counts[en]
  desc "Reset word counts for works in the specified language"
  task(:reset_word_counts, [:lang] => :environment) do |_t, args|
    language = Language.find_by(short: args.lang)
    raise "Invalid language: '#{args.lang}'" if language.nil?

    works = Work.where(language: language)
    print "Resetting word count for #{works.count} '#{language.short}' works: "

    works.find_in_batches do |batch|
      batch.each do |work|
        work.chapters.each do |chapter|
          chapter.content_will_change!
          chapter.save
        end
        work.save
      end
      print(".") && STDOUT.flush
    end
    puts && STDOUT.flush
  end

  desc "Reveal works and creators hidden upon invitation to unrevealed or anonymous collections"
  task(unhide_invited_works: :environment) do
    works = Work.where("in_anon_collection IS true OR in_unrevealed_collection IS true")
    puts "Total number of works to check: #{works.count}"

    works.find_in_batches do |batch|
      batch.each do |work|
        work.update_anon_unrevealed
        work.save if work.changed?
      end
      print(".") && STDOUT.flush
    end
    puts && STDOUT.flush
  end

  desc "Update each user's kudos with the user's id"
  task(add_user_id_to_kudos: :environment) do
    total_users = User.all.size
    total_batches = (total_users + 999) / 1000
    puts "Updating #{total_users} users' kudos in #{total_batches} batches"

    User.includes(:pseuds).find_in_batches.with_index do |batch, index|
      batch_number = index + 1
      progress_msg = "Batch #{batch_number} of #{total_batches} complete"
      batch.each do |user|
        Kudo.where(pseud_id: user.pseud_ids, user_id: nil)
          .update_all(user_id: user.id)
      end
      puts(progress_msg) && STDOUT.flush
    end
    puts && STDOUT.flush
  end

  desc "Update kudo counts on indexed works"
  task(update_indexed_stat_counter_kudo_count: :environment) do
    counters = StatCounter.where("kudos_count > ?", 0)
    total_batches = (counters.size + 999) / 1000
    batch_number = 0

    counters.find_in_batches do |batch|
      batch_number += 1
      progress_msg = "Batch #{batch_number} of #{total_batches} complete"
      batch.each do |counter|
        next unless counter.work

        counter.kudos_count = counter.work.kudos.count
        next unless counter.kudos_count_changed?

        # Counters will be queued for reindexing.
        counter.save
      end
      puts(progress_msg) && STDOUT.flush
    end
    puts && STDOUT.flush
  end

  desc "Clean up the Redis info from the old hit count code."
  task(remove_old_redis_hit_count_data: :environment) do
    REDIS_GENERAL.scan_each(match: "work_stats:*") do |key|
      REDIS_GENERAL.del(key)
    end
  end

  desc "Copy anon_commenting_disabled to comment_permissions."
  task(copy_anon_commenting_disabled_to_comment_permissions: :environment) do
    Work.in_batches do |batch|
      batch.update_all("comment_permissions = anon_commenting_disabled")
      print(".") && STDOUT.flush
    end

    puts && STDOUT.flush
  end

  desc "Replace Archive-hosted Dewplayer embeds with HTML5 audio tags"
  task(replace_dewplayer_embeds: :environment) do
    dewplayer_embed_regex = /<embed .*dewplayer/
    updated_chapter_count = 0
    skipped_chapters = []

    Chapter.find_each do |chapter|
      puts(chapter.id) && STDOUT.flush if (chapter.id % 1000).zero?
      if chapter.content.match(dewplayer_embed_regex)
        begin
          chapter.content_sanitizer_version = -1
          if chapter.sanitize_field(chapter, :content).match(dewplayer_embed_regex)
            # The embed(s) are still there.
            skipped_chapters << chapter.id
          else
            updated_chapter_count += 1
          end
        rescue StandardError
          skipped_chapters << chapter.id
        end
      end
    end

    if skipped_chapters.any?
      puts("Couldn't convert #{skipped_chapters.size} chapter(s): #{skipped_chapters.join(',')}")
      STDOUT.flush
    end
    puts("Converted #{updated_chapter_count} chapter(s).") && STDOUT.flush
  end

  desc "Update the mapping for the work index"
  task(update_work_mapping: :environment) do
    WorkIndexer.create_mapping
  end

  desc "Fix tags with extra spaces"
  task(fix_tags_with_extra_spaces: :environment) do
    total_tags = Tag.count
    total_batches = (total_tags + 999) / 1000
    puts "Inspecting #{total_tags} tags in #{total_batches} batches"

    report_string = ["Tag ID", "Old tag name", "New tag name"].to_csv
    Tag.find_in_batches.with_index do |batch, index|
      batch_number = index + 1
      progress_msg = "Batch #{batch_number} of #{total_batches} complete"

      batch.each do |tag|
        next unless tag.name != tag.name.squish

        old_tag_name = tag.name
        new_tag_name = old_tag_name.gsub(/[[:space:]]/, "_")

        new_tag_name << "_" while Tag.find_by(name: new_tag_name)
        tag.update_attribute(:name, new_tag_name)

        report_row = [tag.id, old_tag_name, new_tag_name].to_csv
        report_string += report_row
      end

      puts(progress_msg) && STDOUT.flush
    end
    puts(report_string) && STDOUT.flush
  end

  desc "Fix works imported with a noncanonical Teen & Up Audiences rating tag"
  task(fix_teen_and_up_imported_rating: :environment) do
    borked_rating_tag = Rating.find_by!(name: "Teen & Up Audiences")
    canonical_rating_tag = Rating.find_by!(name: ArchiveConfig.RATING_TEEN_TAG_NAME)

    work_ids = []
    invalid_work_ids = []
    borked_rating_tag.works.find_each do |work|
      work.ratings << canonical_rating_tag
      work.ratings = work.ratings - [borked_rating_tag]
      if work.save
        work_ids << work.id
      else
        invalid_work_ids << work.id
      end
      print(".") && STDOUT.flush
    end

    unless work_ids.empty?
      puts "Converted '#{borked_rating_tag.name}' rating tag on #{work_ids.size} works:"
      puts work_ids.join(", ")
      STDOUT.flush
    end

    unless invalid_work_ids.empty?
      puts "The following #{invalid_work_ids.size} works failed validations and could not be saved:"
      puts invalid_work_ids.join(", ")
      STDOUT.flush
    end
  end

  desc "Clean up noncanonical rating tags"
  task(clean_up_noncanonical_ratings: :environment) do
    canonical_not_rated_tag = Rating.find_by!(name: ArchiveConfig.RATING_DEFAULT_TAG_NAME)
    noncanonical_ratings = Rating.where(canonical: false)
    puts "There are #{noncanonical_ratings.size} noncanonical rating tags."

    next if noncanonical_ratings.empty?

    puts "The following noncanonical Ratings will be changed into Additional Tags:"
    puts noncanonical_ratings.map(&:name).join("\n")

    work_ids = []
    invalid_work_ids = []
    noncanonical_ratings.find_each do |tag|
      works_using_tag = tag.works
      tag.update_attribute(:type, "Freeform")

      works_using_tag.find_each do |work|
        next unless work.ratings.empty?

        work.ratings = [canonical_not_rated_tag]
        if work.save
          work_ids << work.id
        else
          invalid_work_ids << work.id
        end
        print(".") && STDOUT.flush
      end
    end

    unless work_ids.empty?
      puts "The following #{work_ids.size} works were left without a rating and successfully received the Not Rated rating:"
      puts work_ids.join(", ")
      STDOUT.flush
    end

    unless invalid_work_ids.empty?
      puts "The following #{invalid_work_ids.size} works failed validations and could not be saved:"
      puts invalid_work_ids.join(", ")
      STDOUT.flush
    end
  end

  desc "Clean up noncanonical category tags"
  task(clean_up_noncanonical_categories: :environment) do
    Category.where(canonical: false).find_each do |tag|
      tag.update_attribute(:type, "Freeform")
      puts "Noncanonical Category tag '#{tag.name}' was changed into an Additional Tag."
    end
    STDOUT.flush
  end

  desc "Add default rating to works missing a rating"
  task(add_default_rating_to_works: :environment) do
    work_count = Work.count
    total_batches = (work_count + 999) / 1000
    puts("Checking #{work_count} works in #{total_batches} batches") && STDOUT.flush
    updated_works = []

    Work.find_in_batches.with_index do |batch, index|
      batch_number = index + 1

      batch.each do |work|
        next unless work.ratings.empty?

        work.ratings << Rating.find_by!(name: ArchiveConfig.RATING_DEFAULT_TAG_NAME)
        work.save
        updated_works << work.id
      end
      puts("Batch #{batch_number} of #{total_batches} complete") && STDOUT.flush
    end
    puts("Added default rating to works: #{updated_works}") && STDOUT.flush
  end

  desc "Fix pseuds with invalid icon data"
  task(fix_invalid_pseud_icon_data: :environment) do
    # From validates_attachment_content_type in pseuds model.
    valid_types = %w[image/gif image/jpeg image/png]

    # If you change either of these, update lookup_invalid_pseuds.rb in
    # otwcode/otw-scripts to ensure the proper users are notified.
    pseuds_with_invalid_icons = Pseud.where("icon_file_name IS NOT NULL AND icon_content_type NOT IN (?)", valid_types)
    pseuds_with_invalid_text = Pseud.where("CHAR_LENGTH(icon_alt_text) > ? OR CHAR_LENGTH(icon_comment_text) > ?", ArchiveConfig.ICON_ALT_MAX, ArchiveConfig.ICON_COMMENT_MAX)

    invalid_pseuds = [pseuds_with_invalid_icons, pseuds_with_invalid_text].flatten.uniq
    invalid_pseuds_count = invalid_pseuds.count

    skipped_pseud_ids = []

    # Update the pseuds.
    puts("Updating #{invalid_pseuds_count} pseuds") && STDOUT.flush

    invalid_pseuds.each do |pseud|
      # Change icon content type to jpeg if it's jpg.
      pseud.icon_content_type = "image/jpeg" if pseud.icon_content_type == "image/jpg"
      # Delete the icon if it's not a valid type.
      pseud.icon = nil unless (valid_types + ["image/jpg"]).include?(pseud.icon_content_type)
      # Delete the icon alt text if it's too long.
      pseud.icon_alt_text = "" if pseud.icon_alt_text.length > ArchiveConfig.ICON_ALT_MAX
      # Delete the icon comment if it's too long.
      pseud.icon_comment_text = "" if pseud.icon_comment_text.length > ArchiveConfig.ICON_COMMENT_MAX
      skipped_pseud_ids << pseud.id unless pseud.save
      print(".") && STDOUT.flush
    end
    if skipped_pseud_ids.any?
      puts
      puts("Couldn't update #{skipped_pseud_ids.size} pseud(s): #{skipped_pseud_ids.join(',')}") && STDOUT.flush
    end
  end

  desc "Backfill renamed_at for existing users"
  task(add_renamed_at_from_log: :environment) do
    total_users = User.all.size
    total_batches = (total_users + 999) / 1000
    puts "Updating #{total_users} users in #{total_batches} batches"

    User.find_in_batches.with_index do |batch, index|
      batch.each do |user|
        renamed_at_from_log = user.log_items.where(action: ArchiveConfig.ACTION_RENAME).last&.created_at
        next unless renamed_at_from_log

        user.update_column(:renamed_at, renamed_at_from_log)
      end

      batch_number = index + 1
      progress_msg = "Batch #{batch_number} of #{total_batches} complete"
      puts(progress_msg) && STDOUT.flush
    end
    puts && STDOUT.flush
  end

  desc "Fix threads for comments from 2009"
  task(fix_2009_comment_threads: :environment) do
    def fix_comment(comment)
      comment.with_lock do
        if comment.reply_comment?
          comment.update_column(:thread, comment.commentable.thread)
        else
          comment.update_column(:thread, comment.id)
        end
        comment.comments.each { |reply| fix_comment(reply) }
      end
    end

    incorrect = Comment.top_level.where("thread != id")
    total = incorrect.count

    puts "Updating #{total} thread(s)"

    incorrect.find_each.with_index do |comment, index|
      fix_comment(comment)

      puts "Fixed thread #{index + 1} out of #{total}" if index % 100 == 99
    end
  end

  desc "Convert remaining chapter kudos into work kudos"
  task(clean_up_chapter_kudos: :environment) do
    kudos = Kudo.where(commentable_type: "Chapter")
    kudos_count = kudos.count

    puts("Updating #{kudos_count} chapter kudos") && STDOUT.flush

    indestructible_kudo_ids = []
    unupdatable_kudo_ids = []

    kudos.find_each do |kudo|
      if kudo.commentable.nil? || kudo.commentable.work.nil?
        indestructible_kudo_ids << kudo.id unless kudo.destroy
        print(".") && STDOUT.flush
        next
      end

      kudo.commentable = kudo.commentable.work
      unless kudo.save
        if kudo.errors.keys == [:ip_address] || kudo.errors.keys == [:user_id]
          # If it's a uniqueness problem, orphan the kudo and re-save.
          kudo.ip_address = nil
          kudo.user_id = nil
          unupdatable_kudo_ids << kudo.id unless kudo.save
        else
          # In other cases, let's be cautious and only log.
          unupdatable_kudo_ids << kudo.id
        end
      end
      print(".") && STDOUT.flush
    end

    puts
    puts("Couldn't destroy #{indestructible_kudo_ids.size} kudo(s): #{indestructible_kudo_ids.join(',')}") if indestructible_kudo_ids.any?
    puts("Couldn't update #{unupdatable_kudo_ids.size} kudo(s): #{unupdatable_kudo_ids.join(',')}") if unupdatable_kudo_ids.any?
    STDOUT.flush
  end

  # This is the end that you have to put new tasks above.
end

##################
# ADD NEW MIGRATE TASKS TO THIS LIST ONCE THEY ARE WORKING

# Remove tasks from the list once they've been run on the deployed site
# NOTE:
desc "Run all current migrate tasks"
# task :After => ['After:convert_tag_sets', 'autocomplete:reload_tagset_data', 'skins:disable_all', 'skins:unapprove_all',
# 'skins:load_site_skins', 'After:convert_existing_skins', 'skins:load_user_skins', 'After:remove_old_epubs']
task :After => ['After:locale_setup']
