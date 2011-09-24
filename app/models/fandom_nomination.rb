class FandomNomination < TagNomination
  has_many :character_nominations, :dependent => :destroy
  accepts_nested_attributes_for :character_nominations, :allow_destroy => true, :reject_if => proc { |attrs| attrs[:tagname].blank? }

  has_many :relationship_nominations, :dependent => :destroy
  accepts_nested_attributes_for :relationship_nominations, :allow_destroy => true, :reject_if => proc { |attrs| attrs[:tagname].blank? }


  def character_tagnames
    CharacterNomination.for_tag_set(owned_tag_set).where(:parent_tagname => tagname).value_of :tagname
  end

  def relationship_tagnames
    RelationshipNomination.for_tag_set(owned_tag_set).where(:parent_tagname => tagname).value_of :tagname
  end
  
  
end