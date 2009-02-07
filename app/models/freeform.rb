class Freeform < Tag

  NAME = ArchiveConfig.FREEFORM_CATEGORY_NAME

  before_save :add_fandom_to_parents

  def add_parent(fandom_id)
    add_fandom(fandom_id)
  end

  def characters
    parents.select {|t| t.is_a? Character}.sort
  end

  def pairings
    parents.select {|t| t.is_a? Pairing}.sort
  end

  def freeforms
    (parents + children).select {|t| t.is_a? Freeform}.sort
  end

  def fandoms
    parents.select {|t| t.is_a? Fandom}.sort
  end

  def medias
    parents.select {|t| t.is_a? Media}.sort
  end

end
