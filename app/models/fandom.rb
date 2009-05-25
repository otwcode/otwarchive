class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME

  named_scope :by_media, lambda{|media| {:conditions => {:media_id => media.id}}}
  named_scope :no_parent, :conditions => {:media_id => nil}

  def characters
    children.by_type('Character').by_name
  end

  def pairings
    children.by_type('Pairing').by_name
  end

  def freeforms
    children.by_type('Freeform').by_name
  end

  def fandoms
    (children + parents).select {|t| t.is_a? Fandom}.sort
  end

  def medias
    parents.by_type('Media').by_name
  end

end


