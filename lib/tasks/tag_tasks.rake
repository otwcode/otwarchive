namespace :Tag do
  desc "Reset common taggings - slow"
  task(:reset_common => :environment) do
    Work.find(:all).each do |w|
      print "." if w.id.modulo(100) == 0; STDOUT.flush
      w.update_common_tags
    end
    puts "Common tags reset."
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
  desc "Delete unused tags"
  task(:delete_unused => :environment) do
    Tag.all.each do |t|
      if t.taggings.length == 0 && !t.merger_id && t.mergers.empty? && t.children.length == 0
        t.destroy
      end
    end
  end
end
