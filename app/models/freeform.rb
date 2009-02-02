class Freeform < Tag

  NAME = ArchiveConfig.FREEFORM_CATEGORY_NAME

  before_save :add_fandom_to_parents

  def add_parent(fandom_id)
    add_fandom(fandom_id)
  end

  def add_pairing(pairing_id)
    pairing = Pairing.find_by_id(pairing_id)
    return false unless pairing.is_a? Pairing
    self.wrangle_parent(pairing)
  end

  def update_pairings(new=[])
    current = self.pairings.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |pairing_name|
      Pairing.find_by_name(pairing_name).remove_from_family(self)
    end
    add.each do |pairing_name|
      self.add_pairing(Pairing.find_by_name(pairing_name))
    end
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
