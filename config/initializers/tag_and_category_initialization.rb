begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  TagCategory.initialize_tag_categories
  Tag.initialize_tags
  Work.initialize_tag_category_methods
rescue
  puts "*********************************************************************"
  puts "unable to initialize tags and tag categories and work tag methods"
  puts "ignore this method if you are setting up or resetting a new database"
  puts "*********************************************************************"
end

