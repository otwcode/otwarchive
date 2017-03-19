namespace :Tag do
  desc "Reset common taggings - slow"
  task(:reset_common => :environment) do
    Work.find(:all).each do |w|
      print "." if w.id.modulo(100) == 0; STDOUT.flush
      #w.update_common_tags
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

  desc "Reset taggings count for obviously wrong taggings_count"
  task(:fix_taggings_count => :environment) do
    tag_scope = Tag.where("taggings_count < 0")
    tag_count = tag_scope.count
    tag_scope.each_with_index do |tag, index|
      puts "#{index} / #{tag_count}"
      Tag.reset_counters(tag.id, :taggings)
    end
    puts "Taggings count for less-than-zero counts has been reset."
  end

  desc "Update relationship has_characters"
  task(:update_has_characters => :environment) do
    Relationship.all.each do |relationship|
      relationship.update_attribute(:has_characters, true) unless relationship.characters.blank?
    end
  end

  desc "Delete unused tags"
  task(:delete_unused => :environment) do
    deleted_names = []
    Tag.find(:all, :conditions => {:canonical => false, :merger_id => nil, :taggings_count => 0}).each do |t|
      if t.taggings.count == 0 && t.child_taggings.count == 0 && t.set_taggings.count == 0
        deleted_names << t.name
        t.destroy
      end
    end
    unless deleted_names.blank?
      puts "The following #{deleted_names.length} unused tags were deleted:"
      puts deleted_names.join(", ")
    end
  end
  
  desc "Delete unused admin post tags"
  task(:delete_unused_admin_post_tags => :environment) do
    AdminPostTag.joins("LEFT JOIN `admin_post_taggings` ON admin_post_taggings.admin_post_tag_id = admin_post_tags.id").where("admin_post_taggings.id IS NULL").destroy_all
  end

  desc "Clean up orphaned taggings"
  task(:clean_up_taggings => :environment) do
    Tagging.find_each {|t| t.destroy if t.taggable.nil?}
    CommonTagging.find_each {|t| t.destroy if t.common_tag.nil?}
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
  desc "Reset filter counts from date"
  task(:unsuspend_filter_counts => :environment) do
    admin_settings = Rails.cache.fetch("admin_settings") { AdminSetting.first }
    if admin_settings && admin_settings.suspend_filter_counts_at
      FilterTagging.update_filter_counts_since(admin_settings.suspend_filter_counts_at)
    end
  end
end
