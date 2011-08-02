class FandomNomination < TagNomination
  has_many :character_nominations, :dependent => :destroy
  accepts_nested_attributes_for :character_nominations, :allow_destroy => true

  has_many :relationship_nominations, :dependent => :destroy
  accepts_nested_attributes_for :relationship_nominations, :allow_destroy => true
end