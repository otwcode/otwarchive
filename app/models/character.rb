class Character < Tag

  NAME = ArchiveConfig.CHARACTER_CATEGORY_NAME

  before_save :add_fandom_to_parents

  def add_pairing(pairing_id)
    pairing = Pairing.find_by_id(pairing_id)
    return false unless pairing.is_a? Pairing
    pairing.wrangle_parent(self)
    pairing.update_attribute(:has_characters, true)
  end

  def update_pairings(new=[])
    current = self.pairings.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |pairing_name|
      pairing = Pairing.find_by_name(pairing_name)
      pairing.remove_from_family(self)
      pairing.reload
      pairing.update_attribute(:has_characters, false) unless pairing.characters
    end
    add.each do |pairing_name|
      self.add_pairing(Pairing.find_by_name(pairing_name))
    end
  end

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
