class CharacterNomination < TagNomination
  belongs_to :fandom_nomination

  validate :known_fandom
  def known_fandom
    return true if self.fandom_nomination || self.parent_tagname
    return true if (tag = Character.find_by_name(self.tagname)) && tag.parents.any? {|p| p.is_a?(Fandom)}
    errors.add(:base, ts("We need to know what fandom your character tag %{tagname} belongs in.", :tagname => self.tagname))
  end

  before_save :set_parented
  def set_parented
    has_parent = (tag = Character.find_by_name(tagname)) && tag.parents.any? {|p| p.is_a?(Fandom)}
    self.parented = has_parent ? true : false
    true
  end
  
  before_save :set_tag_set_nomination
  def set_tag_set_nomination
    if fandom_nomination && !tag_set_nomination
      self.tag_set_nomination = fandom_nomination.tag_set_nomination
    end
  end

end