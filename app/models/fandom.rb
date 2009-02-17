class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME

  named_scope :by_media, lambda{|media| {:conditions => {:media_id => media.id}}}
  named_scope :no_parent, :conditions => {:media_id => nil}

  def characters
    children.select {|t| t.is_a? Character}.sort
  end

  def pairings
    children.select {|t| t.is_a? Pairing}.sort
  end

  def freeforms
    children.select {|t| t.is_a? Freeform}.sort
  end

  def fandoms
    (children + parents).select {|t| t.is_a? Fandom}.sort
  end

  def medias
    parents.select {|t| t.is_a? Media}.sort
  end

end


