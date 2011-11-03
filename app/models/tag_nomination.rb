class TagNomination < ActiveRecord::Base
  belongs_to :tag_set_nomination, :inverse_of => :tag_nominations
  has_one :owned_tag_set, :through => :tag_set_nomination
  
  attr_accessor :from_fandom_nomination

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
      errors.add(:base, ts("^The tag %{tagname} is already in the archive as a #{tag.type} tag. Try being more specific, for instance tacking on the media (TV) or the fandom (Labyrinth) that your nomination belongs to.", :tagname => self.tagname))
    end
  end

  validate :not_already_reviewed, :on => :update
  def not_already_reviewed
    if tagname_changed? && (tagname != tagname_was) && (self.approved || self.rejected) 
      errors.add(:base, ts("^You cannot change %{tagname_was} to %{tagname} because that nomination has already been reviewed.", :tagname_was => self.tagname_was, :tagname => self.tagname))
      tagname = self.tagname_was
    end
    false
  end
  
  # This makes sure no tagnames are nominated for different parents in this tag set
  validate :require_unique_tagname_with_parent
  def require_unique_tagname_with_parent
    query = TagNomination.for_tag_set(get_owned_tag_set).where(:tagname => self.tagname).where("parent_tagname != ?", (self.get_parent_tagname || ''))
    # let people change their own!
    query = query.where("tag_nominations.id != ?", self.id) if !(self.new_record?)
    if query.exists?
      errors.add(:base, ts("^Someone else has already nominated %{tagname} for this set but in a different fandom. Please be more specific.", :tagname => self.tagname))
    end
  end

  def get_owned_tag_set
    @tag_set || self.tag_set_nomination.owned_tag_set
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

  before_save :set_parented
  def set_parented    
    if type == "FreeformNomination"
      # skip freeforms
      self.parented = true
    elsif (tag = Tag.find_by_name(tagname)) && 
      ((!tag.parents.empty? && get_parent_tagname.blank?) || tag.parents.collect(&:name).include?(get_parent_tagname))
      # if this is an existing tag and has matching parents, or no parent specified and it already has one 
      self.parented = true
      self.parent_tagname ||= get_parent_tagname
    else
      self.parented = false
      self.parent_tagname ||= get_parent_tagname 
    end   
    true
  end
  
  # sneaky bit: if the tag set moderator has already rejected or approved this tag, don't 
  # show it to them again.
  before_save :set_approval_status
  def set_approval_status
    set_noms = tag_set_nomination
    set_noms = fandom_nomination.tag_set_nomination if !set_noms && from_fandom_nomination    
    self.rejected = set_noms.owned_tag_set.already_rejected?(tagname) || false
    if self.rejected
      self.approved = false
    else
      self.approved = set_noms.owned_tag_set.already_in_set?(tagname) || (synonym && set_noms.owned_tag_set.already_in_set?(synonym)) || false
    end
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
  
  # returns an array of all the parent tagnames for the given tag 
  # can be chained with other queries but must come at the end
  def self.nominated_parents(child_tagname, parent_search_term="")
    parents = where(:tagname => child_tagname).where("parent_tagname != ''")
    unless parent_search_term.blank?
      parents = parents.where("parent_tagname LIKE ?", "%#{parent_search_term}%")
    end
    parents.group("parent_tagname").order("count_id DESC").count('id').keys
  end
  
  # We need this manual join in order to do a query over multiple types of tags
  # (ie, via TagNomination.where(:type => ...))
  def self.join_fandom_nomination
    joins("INNER JOIN tag_nominations fandom_nominations_tag_nominations ON 
      fandom_nominations_tag_nominations.id = tag_nominations.fandom_nomination_id AND 
      fandom_nominations_tag_nominations.type = 'FandomNomination'")
  end

  # Can we change the name to this new name?
  def change_tagname?(new_tagname)
    self.tagname = new_tagname
    if self.valid?
      return true
    else
      return false
    end
  end

  # If the mod is changing our name, change all other noms in this set as well
  # NOTE: YOU CAN ONLY USE THIS IF YOU SUBSEQUENTLY MANUALLY UPDATE THE STATUS OF ALL THE TAG NOMS
  def change_tagname!(new_tagname)
    old_tagname = self.tagname
    if change_tagname?(new_tagname)
      # name change is ok - we use update_all because we assume our status is being updated up a level
      TagNomination.for_tag_set(owned_tag_set).where(:tagname => old_tagname).update_all(:tagname => new_tagname)
      return true
    end
    return false
  end

  # here so we can override it in char/relationship noms
  def get_parent_tagname
    self.parent_tagname.present? ? self.parent_tagname : nil
  end
  
  def unreviewed?
    !approved && !rejected
  end
  
  def reviewed?
    approved || rejected
  end

  def times_nominated(tag_set)
    TagNomination.for_tag_set(tag_set).where(:tagname => self.tagname).count
  end
  
end
