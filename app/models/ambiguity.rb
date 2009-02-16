class Ambiguity < Tag

  NAME = ArchiveConfig.AMBIGUOUS_CATEGORY_NAME

  def disambiguators
    CommonTagging.find_all_by_filterable_id_and_filterable_type(self.id, 'Tag').map(&:common_tag).uniq.compact.sort
  end

  # in the case where something is made ambiguous, and then
  # it is changed back to a user created tag
  # it needs to be able to access its relatives
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
