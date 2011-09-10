class RelationshipNomination < TagNomination
  belongs_to :fandom_nomination

  validate :known_fandom
  def known_fandom
    return true if (!parent_tagname.blank? || self.fandom_nomination || from_fandom_nomination)
    return true if (tag = Relationship.find_by_name(self.tagname)) && tag.parents.any? {|p| p.is_a?(Fandom)}
    errors.add(:base, ts("^We need to know what fandom your relationship tag %{tagname} belongs in.", :tagname => self.tagname))
  end

  before_save :set_tag_set_nomination
  def set_tag_set_nomination
    if fandom_nomination && !tag_set_nomination
      self.tag_set_nomination = fandom_nomination.tag_set_nomination
    end
  end
    
  def get_parent_tagname
    (self.parent_tagname.blank? ? self.parent_tagname : nil) || (self.fandom_nomination ? self.fandom_nomination.tagname : nil)
  end


end