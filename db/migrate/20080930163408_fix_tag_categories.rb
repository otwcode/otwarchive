class FixTagCategories < ActiveRecord::Migration
  def self.up
    genre = TagCategory.find_by_name('genre')
    category = TagCategory::CATEGORY
    
    unless genre.nil? || category.nil?
      # we have both genre & category, ugh
      
      # 1) Update all tags in the 'category' category to be in the 'genre' category
      TagCategory::CATEGORY.tags.each do |tag|
        tag.tag_category_id = genre.id
        tag.save
      end
      
      # 2) Delete the 'category' category
      category.destroy

      # 3) Change the 'genre' category name to 'category'
      genre.name = 'category'
      genre.save
    end
    
    TagCategory.official.each do |cat|
      # 4) For all other categories set the display name to be the name
      cat.display_name = cat.name.capitalize
      # 5) For all categories set the name to be lowercase
      cat.name = cat.display_name.downcase
      cat.save
    end
  end

  def self.down
  end
end
