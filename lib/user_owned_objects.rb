module UserOwnedObjects
  
  # fetch all creations a user own (via pseuds)
  def creations
    pseuds.collect(&:creations).reject(&:empty?).flatten
  end
  
  # Find all works for a given user
  def works
    pseuds.collect(&:works).reject(&:empty?).flatten
  end
  
  # Find all chapters for a given user
  def chapters
    pseuds.collect(&:chapters).reject(&:empty?).flatten  
  end
  
  # Find all series for a given user
  def series
    pseuds.collect(&:series).reject(&:empty?).flatten  
  end
  
  # Get the total number of series for a given user
  def series_count
    series.length  
  end
  
  # Get the total number of works for a given user
  def work_count
		works.length
	end  
  
  # Returns an array (of pseuds) of this user's co-authors
  def coauthors
     creations.collect(&:pseuds).flatten.uniq - pseuds
  end
  
  # Gets the user's one allowed unposted work
  def unposted_work
    works.select{|w| w.posted != true}.first
  end
  
  # Gets the user's one allowed unposted chapter per work
  def unposted_chapter(work)
    chapters.select{|c| c.work_id == work.id && c.posted != true}.first
  end 
  
  # Find all comments for a given user
  def comments
    Comment.find(:all, :conditions => ["pseud_id IN (?)", self.pseuds.collect(&:id).to_s])
  end
  
end