class TagNomination < ActiveRecord::Base
  belongs_to :tag_set_nomination
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
    self.approved = set_noms.owned_tag_set.already_in_set?(tagname) || (synonym && set_noms.owned_tag_set.already_in_set?(synonym)) || false
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

  # Can we change the name to this new name?
  def change_tagname?(new_tagname)
    tagname = new_tagname
    if self.valid?
      return true
    else
      return false
    end
  end

  # If the mod is changing our name, change all other noms in this set as well
  # NOTE: YOU CAN ONLY USE THIS IF YOU SUBSEQUENTLY MANUALLY UPDATE THE STATUS OF ALL THE TAG NOMS
  def change_tagname!(new_tagname)
    if change_tagname?(new_tagname)
      # name change is ok - we use update_all because we assume our status is being updated up a level
      TagNomination.for_tag_set(owned_tag_set).where(:tagname => tagname).update_all(:tagname => new_tagname)
      return true
    end
    return false
  end

  # here so we can override it in char/relationship noms
  def get_parent_tagname
    (self.parent_tagname.blank? ? self.parent_tagname : nil)
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
