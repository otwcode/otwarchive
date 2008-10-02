class StripLeadingSpacesFromTitles < ActiveRecord::Migration
  def self.up
    Work.find(:all, :conditions => ["INSTR(title, ' ') = 1"]).each do |work|
      unless work.clean_and_validate_title
        if work.title.blank?
          work.title = "Untitled"
        end
      end
      work.save
    end
    
    Chapter.find(:all, :conditions => ["INSTR(title, ' ') = 1"]).each do |chapter|
      chapter.clean_title
      chapter.save
    end
    
  end

  def self.down
  end
end
