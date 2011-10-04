class RelationshipNomination < TagNomination
  belongs_to :tag_set_nomination #, :inverse_of => :relationship_nominations
  has_one :owned_tag_set, :through => :tag_set_nomination #, :inverse_of => :relationship_nominations
  belongs_to :fandom_nomination #, :inverse_of => :relationship_nominations

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
    self.parent_tagname.present? ? self.parent_tagname : (
      self.fandom_nomination ? self.fandom_nomination.tagname : 
        Tag.find_by_name(self.tagname).try(:parents).try(:first).try(:name))
  end


end