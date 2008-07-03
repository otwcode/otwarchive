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
  
  # Get the total number of works for a given user
  def work_count
    pseuds.collect{|pseud| pseud.works.count}.sum
  end 
  
  # Returns an array (of pseuds) of this user's co-authors
  def coauthors
     creations.collect(&:pseuds).flatten.uniq - pseuds
  end
  
  # Gets the user's one allowed unposted work
  def unposted_work
    creations.select{|c| c.class == Work && c.posted != true}.first
  end
  
  # Gets the user's one allowed unposted chapter per work
  def unposted_chapter(work)
    creations.select{|c| c.class == Chapter && c.work_id == work.id && c.posted != true}.first
  end 
  
  # Find all comments for a given user
  def comments
    pseuds.collect{|pseud| Comment.find_all_by_pseud_id(pseud.id)}.reject(&:empty?).flatten
  end
  
  # TODO: Needs refinement!
  # Find all comments left on things that belong to this user
  def feedback
     fb = ([self] + chapters + comments).collect(&:comments).reject(&:empty?).flatten
     fb.sort {|x,y| y.created_at <=> x.created_at }.uniq
  end
  
end