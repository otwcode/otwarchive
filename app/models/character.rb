class Character < Tag

  NAME = ArchiveConfig.CHARACTER_CATEGORY_NAME

  before_save :add_fandom_to_parents

  def characters
    (children + parents).select {|t| t.is_a? Character}.sort
  end

  def pairings
    children.select {|t| t.is_a? Pairing}.sort
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
