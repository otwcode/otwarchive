class FandomNomination < TagNomination
  has_many :character_nominations, :dependent => :destroy
  accepts_nested_attributes_for :character_nominations, :allow_destroy => true, :reject_if => proc { |attrs| attrs[:tagname].blank? }

  has_many :relationship_nominations, :dependent => :destroy
  accepts_nested_attributes_for :relationship_nominations, :allow_destroy => true, :reject_if => proc { |attrs| attrs[:tagname].blank? }

  validate :known_media
  def known_media
    return true if !parent_tagname.blank?
    return true if (tag = Fandom.find_by_name(self.tagname)) && tag.parents.any? {|p| p.is_a?(Media)}
    errors.add(:base, ts("^We need to know what type your new fandom tag %{tagname} belongs in.", :tagname => self.tagname))
    false
  end
  

end