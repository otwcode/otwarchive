class Pairing < Tag

  NAME = ArchiveConfig.PAIRING_CATEGORY_NAME

  named_scope :no_characters, :conditions => {:has_characters => false}

  def characters
    parents.select {|t| t.is_a? Character}.sort
  end

  def pairings
    (parents + children).select {|t| t.is_a? Pairing}.sort
  end

  def freeforms
    children.select {|t| t.is_a? Freeform}.sort
  end

  def fandoms
    parents.select {|t| t.is_a? Fandom}.sort
  end

  def medias
    parents.select {|t| t.is_a? Media}.sort
  end

end
