class TagNomination < ActiveRecord::Base
  belongs_to :tag_set_nomination

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
      errors.add(:base, ts("The tag %{tagname} is already in the archive but as a #{tag.type} tag.", :tagname => self.tagname))
    end
  end
  
  before_save :set_canonical
  def set_canonical
    self.canonical = !Tag.canonical.find_by_name(tagname).nil?
  end
  
  before_save :set_exists
  def set_exists
    self.exists = !Tag.find_by_name(tagname).nil?
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
