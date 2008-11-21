class Ambiguity < Tag

  NAME = ArchiveConfig.AMBIGUOUS_CATEGORY_NAME

  def add_disambiguator(tag)
    self.disambiguators << tag rescue nil
  end
end
