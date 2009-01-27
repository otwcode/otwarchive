def create_canonical(name, type, adult=false)
  tag = type.find_by_name(name)
  unless tag
    begin
      tag = type.create!(:name=> name)
    rescue
      old_tag = Tag.find_by_name(name)
      old_tag.update_attribute(:name, old_tag.name + " - " + old_tag[:type])
      tag = type.create(:name => name)
    end
  end
  tag.update_attribute(:canonical,true)
  tag.update_attribute(:adult, adult)
  raise "how did this happen?" unless tag.canonical?
  return tag
end

begin
  tag = Warning.new(:name => "unused")
  raise unless tag[:type]  # haven't migrated to STI yet
  raise unless tag.unwrangled # haven't run with new migrations
rescue
  puts "no STI"
else
  create_canonical(ArchiveConfig.WARNING_DEFAULT_TAG_NAME, Warning)
  create_canonical(ArchiveConfig.WARNING_NONE_TAG_NAME, Warning)
  create_canonical(ArchiveConfig.WARNING_SOME_TAG_NAME, Warning)
  create_canonical(ArchiveConfig.WARNING_VIOLENCE_TAG_NAME, Warning)
  create_canonical(ArchiveConfig.WARNING_DEATH_TAG_NAME, Warning)
  create_canonical(ArchiveConfig.WARNING_NONCON_TAG_NAME, Warning)
  create_canonical(ArchiveConfig.WARNING_CHAN_TAG_NAME, Warning)
  create_canonical(ArchiveConfig.RATING_DEFAULT_TAG_NAME, Rating, true)
  create_canonical(ArchiveConfig.RATING_EXPLICIT_TAG_NAME, Rating, true)
  create_canonical(ArchiveConfig.RATING_MATURE_TAG_NAME, Rating, true)
  create_canonical(ArchiveConfig.RATING_TEEN_TAG_NAME, Rating, false)
  create_canonical(ArchiveConfig.RATING_GENERAL_TAG_NAME, Rating, false)
  create_canonical(ArchiveConfig.CATEGORY_HET_TAG_NAME, Category)
  create_canonical(ArchiveConfig.CATEGORY_SLASH_TAG_NAME, Category)
  create_canonical(ArchiveConfig.CATEGORY_FEMSLASH_TAG_NAME, Category)
  create_canonical(ArchiveConfig.CATEGORY_GEN_TAG_NAME, Category)
  create_canonical(ArchiveConfig.CATEGORY_MULTI_TAG_NAME, Category)
  create_canonical(ArchiveConfig.CATEGORY_OTHER_TAG_NAME, Category)
  create_canonical(ArchiveConfig.MEDIA_NO_TAG_NAME, Media)
end
