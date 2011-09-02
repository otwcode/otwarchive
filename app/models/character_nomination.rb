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
    if has_parent
      self.parented = true
    else
      self.parented = false
      self.parent_tagname = self.fandom_nomination.tagname unless self.parent_tagname
    end   
    true
  end
  
  before_save :set_tag_set_nomination
  def set_tag_set_nomination
    if fandom_nomination && !tag_set_nomination
      self.tag_set_nomination = fandom_nomination.tag_set_nomination
    end
  end

  def nominated_parents
    TagNomination.where(:parented => false, :tagname => self.tagname).select("parent_tagname, count(*) as count").group("parent_tagname").order("count DESC")
  end

end