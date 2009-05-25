class Pairing < Tag

  NAME = ArchiveConfig.PAIRING_CATEGORY_NAME

  named_scope :no_characters, :conditions => {:has_characters => false}

  def characters
    parents.by_type('Character').by_name
  end

  def all_characters
    all = self.characters
    if self.merger
      all << self.merger.characters
    end
    all_with_synonyms = all.flatten.uniq.compact
    all_with_synonyms << all_with_synonyms.collect{|c| c.mergers}
    all_with_synonyms.flatten.uniq.compact
  end

  def pairings
    (parents + children).select {|t| t.is_a? Pairing}.sort
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
