class TagSetNomination < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :owned_tag_set
  
  validates_presence_of :owned_tag_set_id
  validates_presence_of :pseud_id
  
  validates :can_nominate
  def can_nominate
    unless owned_tag_set.nominated
      errors.add(:owned_tag_set, ts("That tag set is not currently accepting nominations."))
    end
  end
  
  validates :tag_validity
  def tag_validity
  end


  validates :nomination_limits
  def nomination_limits
  end
  
end
