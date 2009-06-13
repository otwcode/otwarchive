namespace :Tag do
  desc "Reset common taggings - slow"
  task(:reset_common => :environment) do
    ThinkingSphinx.deltas_enabled=false
    Work.find(:all).each do |w|
      print "." if w.id.modulo(100) == 0; STDOUT.flush
      w.update_common_tags
    end
    puts "Common tags reset."
    ThinkingSphinx.deltas_enabled=true
  end
  desc "Reset tag count"
  task(:reset_count => :environment) do
    Tag.find(:all).each do |t|
      Tag.update_counters t.id, :taggings_count => -t.taggings_count
      Tag.update_counters t.id, :taggings_count => t.taggings.length
    end
    puts "Tag count reset."
  end
  desc "Reset tag fandom and media ids"
  task(:reset_parents => :environment) do
    ThinkingSphinx.deltas_enabled=false
    nofandom = Tag.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
    Tag.find(:all).each do |t|
      t.parents.delete(nofandom) if t.is_a?(Fandom)
      t.update_attribute(:fandom_id, nil) if t.is_a?(Fandom)
      t.update_attribute(:media_id, nil) if t.is_a?(Media)
      t.ensure_correct_media_id if t.media_id
      t.ensure_correct_fandom_id if t.fandom_id
    end
    ThinkingSphinx.deltas_enabled=true
    puts "Tag parents reset."
  end
  desc "Update pairing has_characters"
  task(:update_has_characters => :environment) do
    Pairing.all.each do |pairing|
      pairing.update_attribute(:has_characters, true) unless pairing.characters.blank?
    end
  end
  desc "Delete unused tags"
  task(:delete_unused => :environment) do
    deleted_names = []
    Tag.all.each do |t|
      if t.taggings.length == 0 && !t.merger_id && t.mergers.empty? && !t.canonical && t.common_taggings.length == 0
        deleted_names << t.name
        t.destroy
      end
    end
    unless deleted_names.blank?
      puts "The following unused tags were deleted:"
      puts deleted_names.join(", ")
    end
  end
  desc "Reset filter taggings"
  task(:reset_filters => :environment) do
    FilterTagging.delete_all
    FilterTagging.build_from_taggings
  end
  desc "Reset filter counts"
  task(:reset_filter_counts => :environment) do
    FilterCount.set_all
  end
end
