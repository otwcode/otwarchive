class TagNomination < ActiveRecord::Base
  belongs_to :tag_set_nomination
  has_one :owned_tag_set, :through => :tag_set_nomination

  validates_length_of :tagname,
    :maximum => ArchiveConfig.TAG_MAX,
    :message => "of tag is too long -- try using less than #{ArchiveConfig.TAG_MAX} characters."
  validates_format_of :tagname,
    :if => "!tagname.blank?",
    :with => /\A[^,*<>^{}=`\\%]+\z/,
    :message => 'of a tag can not include the following restricted characters: , ^ * < > { } = ` \\ %'
  
  validate :type_validity
  def type_validity
    if !tagname.blank? && (tag = Tag.find_by_name(tagname)) && "#{tag.type}Nomination" != self.type
      errors.add(:base, ts("^The tag %{tagname} is already in the archive but as a #{tag.type} tag.", :tagname => self.tagname))
    end
  end

  validate :not_already_approved, :on => :update
  def not_already_approved
    if tagname_changed? && (tagname != tagname_was) && (self.approved || self.rejected) 
      errors.add(:base, ts("^You cannot change %{tagname_was} to %{tagname} because that nomination has already been reviewed.", :tagname_was => self.tagname_was, :tagname => self.tagname))
      tagname = self.tagname_was
    end
    false
  end

  before_save :set_tag_status
  def set_tag_status
    if (tag = Tag.find_by_name(tagname))
      self.exists = true
      self.tagname = tag.name
      self.canonical = tag.canonical
      self.synonym = tag.merger ? tag.merger.name : nil
    else
      self.exists = false
      self.canonical = false
      self.synonym = nil
    end
    true
  end
  
  # sneaky bit: if the tag set moderator has already rejected or approved this tag, don't 
  # show it to them again.
  before_save :set_approval_status
  def set_approval_status
    self.rejected = tag_set_nomination.owned_tag_set.already_rejected?(tagname)
    self.approved = tag_set_nomination.owned_tag_set.already_in_set?(tagname) || tag_set_nomination.owned_tag_set.already_approved?(tagname)
    true
  end

  def self.for_tag_set(tag_set)
    joins(:tag_set_nomination => :owned_tag_set).
    where("owned_tag_sets.id = ?", tag_set.id)
  end

  def self.names_with_count
    select("tagname, count(*) as count").group("tagname").order("tagname")
  end
  
  def self.unreviewed
    where(:approved => false).where(:rejected => false)
  end
  
end
