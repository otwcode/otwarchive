begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  if TagCategory.count==0
   ArchiveConfig.FIRST_CATEGORIES.each do |hash|
     TagCategory.create(hash)
   end
  end
  if TagCategory.official_tags('Rating').size == 0
    rating_category = TagCategory.find_by_name('rating')
    ArchiveConfig.FIRST_RATINGS.each do |rating|
      Tag.create(:name => rating, :canonical => true, :tag_category => rating_category)
    end
  end
rescue
end
