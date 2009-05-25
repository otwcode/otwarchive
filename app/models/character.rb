class Character < Tag

  NAME = ArchiveConfig.CHARACTER_CATEGORY_NAME
  
  named_scope :by_pairings, lambda {|pairings| 
    {:select => 'DISTINCT tags.*', :joins => :children, :conditions => ['childrens_tags.id IN (?)', pairings.collect(&:id)]}
  }

  def characters
    (children + parents).select {|t| t.is_a? Character}.sort
  end

  def pairings
    children.by_type('Pairing').by_name
  end

  def freeforms
    children.by_type('Freeform').by_name
  end

  def fandoms
    parents.by_type('Fandom').by_name
  end

  def medias
    parents.by_type('Media').by_name
  end

end
