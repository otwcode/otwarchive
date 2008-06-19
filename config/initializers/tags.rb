begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue

  # if there are no categories, set some up to look nice
  if TagCategory.count==0
   ArchiveConfig.FIRST_CATEGORIES.each do |hash|
     TagCategory.create(hash)
   end
  end

  # if there is not an ambiguous category set it up
  # it is required by some methods
  t = TagCategory.find_by_name(ArchiveConfig.AMBIGUOUS_CATEGORY)
  if t
    puts 'your AMBIGUOUS tag category does not have typical settings, this may cause unanticipated results' if t.required? || t.official? || t.exclusive?
  else
    TagCategory.create({ :name => ArchiveConfig.AMBIGUOUS_CATEGORY, :required => false, :official => false, :exclusive => false })
  end

  # if there is not a default category set it up
  # it is required by some methods
  t = TagCategory.find_by_name(ArchiveConfig.DEFAULT_CATEGORY)
  if t
    puts 'your DEFAULT tag category does not have typical settings, this may cause unanticipated results' if t.required? || !t.official? || t.exclusive?
  else
    TagCategory.create({ :name => ArchiveConfig.DEFAULT_CATEGORY, :required => false, :official => true, :exclusive => false })
  end

rescue
end
