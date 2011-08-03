class CharacterNomination < TagNomination
  belongs_to :fandom_nomination

  validate :known_fandom
  def known_fandom
    return true if self.fandom_nomination || self.parent_tagname
    return true if (tag = Character.find_by_name(self.tagname)) && tag.parents.any? {|p| p.is_a?(Fandom)}
    errors.add(:base, ts("We need to know what fandom your character tag %{tagname} belongs in.", :tagname => self.tagname))
  end

end