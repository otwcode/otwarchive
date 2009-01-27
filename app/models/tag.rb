class Tag < ActiveRecord::Base

  # Note: the order of this array is important.
  # It is the order that tags are shown in the header of a work
  # (ambiguous tags are grouped with freeform tags)
  # (banned tags are not shown)
  TYPES = ['Rating', 'Warning', 'Category', 'Media', 'Fandom', 'Pairing', 'Character', 'Freeform', 'Ambiguity', 'Banned' ]

  # these tags can be filtered on
  FILTERS = TYPES - ['Ambiguity', 'Banned', 'Media']

  # these tags show up on works
  VISIBLE = TYPES - ['Media', 'Banned']

  # these tags can be created by users
  USER_DEFINED = ['Fandom', 'Pairing', 'Character', 'Freeform']

  has_many :mergers, :foreign_key => 'merger_id', :class_name => 'Tag'
  belongs_to :merger, :class_name => 'Tag'
  belongs_to :fandom
  belongs_to :media

  has_many :common_taggings, :foreign_key => 'common_tag_id'
  has_many :parents, :through => :common_taggings, :source => :filterable, :source_type => 'Tag'
  has_many :ambiguities, :through => :common_taggings, :source => :filterable, :source_type => 'Ambiguity'
  has_many :filtered_works, :through => :common_taggings, :source => :filterable, :source_type => 'Work'

  has_many :taggings, :as => :tagger
  has_many :works, :through => :taggings, :source => :taggable, :source_type => 'Work'
  has_many :bookmarks, :through => :taggings, :source => :taggable, :source_type => 'Bookmark'
  has_many :external_works, :through => :taggings, :source => :taggable, :source_type => 'ExternalWork'

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => ArchiveConfig.TAG_MAX,
                             :message => "is too long -- try using less than #{ArchiveConfig.TAG_MAX} characters or using commas to separate your tags.".t
  validates_format_of :name,
                      :with => /\A[-a-zA-Z0-9 \/?.!''"":;\|\]\[}{=~!@#\$%^&()_+]+\z/,
                      :message => "can only be made up of letters, numbers, spaces and basic punctuation, but not commas, asterisks or angle brackets.".t

  def before_validation
    self.name = name.squish if self.name
  end

  named_scope :canonical, {:conditions => {:canonical => true}, :order => 'name ASC'}
  named_scope :nonsynonymous, {:conditions => {:merger_id => nil, :canonical => false}, :order => 'name ASC'}
  named_scope :unwrangled, {:conditions => {:wrangled => false}, :order => 'name ASC'}
  named_scope :visible, {:conditions => ['type in (?)', VISIBLE], :order => 'name ASC' }

  named_scope :by_popularity, {:order => 'taggings_count DESC'}
  named_scope :by_name, {:order => 'name ASC'}

  named_scope :by_fandom, lambda{|fandom| {:conditions => {:fandom_id => fandom.id}}}
  named_scope :no_fandom, :conditions => {:fandom_id => nil}

  # Class methods

  def self.string
    all.map(&:name).join(ArchiveConfig.DELIMITER)
  end

  def to_param
    name
  end

  def self.find_or_create_by_name(string, update_works=true)
    return if !string.is_a?(String) || string.blank?
    string.squish!
    # try to find the tag
    tag = self.find_by_name(string)
    return tag if tag
    # try to create the tag
    tag = self.create(:name => string)
    return tag if tag.valid?
    # see if you can find a tag with the same name and make it ambiguous
    old_tag = Tag.find_by_name(string)
    old_tag.wrangle_ambiguous(update_works) if old_tag
    return old_tag if old_tag
  end

  # FIXME make more efficient
  def self.for_tag_cloud
    tags = Freeform.canonical.all
    tag_cloud = tags.dup
    tags.each do |t|
      tag_cloud.delete(t) if t.merger
      tag_cloud.delete(t) if t.parents.size > 0
      tag_cloud.delete(t) if t.visible_works_count == 0 && !t.mergers
    end
    tag_cloud.sort
  end

  # Instance methods that are common to all subclasses (may be overridden in the subclass)

  def banned
    return true if self.class == 'Banned'
  end

  # sort tags by name
  def <=>(another_tag)
    name.downcase <=> another_tag.name.downcase
  end


  def update_common_tags
    self.works.each do |work|
      work.update_common_tags
    end
  end

  def wrangle_banned(update_works=true)
    self.update_attribute(:type, "Banned")
    self.common_taggings.clear
    self.update_common_tags if update_works
  end

  def wrangle_ambiguous(update_works=true)
    self.update_attribute(:type, "Ambiguity")
    self.common_taggings.clear
    self.update_common_tags if update_works
  end

  def wrangle_canonical(update_works=true)
    self.update_attribute(:canonical, true)
    self.update_attribute(:merger_id, nil)
    self.update_common_tags if update_works
  end

  def wrangle_not_canonical(update_works=true)
    self.update_attribute(:canonical, false)
    self.common_taggings.clear if update_works
    self.update_common_tags if update_works
  end

  def wrangle_merger(tag, update_works=true)
    return unless tag.canonical? && tag.is_a?(self.class)
    self.update_attribute(:merger_id, tag.id)
    self.update_attribute(:canonical, false)
    self.parents.clear
    self.children.each do |child|
      child.parents.delete(self)
      child.wrangle_parent(tag, update_works)
    end
    self.children.clear
    self.update_common_tags if update_works
  end

  def wrangle_parent(parent, update_works=true)
    return unless parent.is_a?(Tag) && parent.canonical?
    self.parents << parent rescue nil
    self.update_common_tags if update_works
  end

  # all tags which have given tag as a parent
  def children
    CommonTagging.find_all_by_filterable_id_and_filterable_type(self.id, 'Tag').map(&:common_tag).uniq.compact.sort
  end

  # parents children and self
  def family
    [self] + self.children + self.parents
  end

  def remove_from_family(tag)
    if self.parents.include?(tag)
      self.parents.delete(tag)
    elsif tag.parents.include?(self)
      tag.parents.delete(self)
    else
      return false
    end
  end

  # Tag       Tag_to_add    Relationship
  #  All        Media         Parent
  #  All        Fandom        Parent
  #  All        Freeform      Child
  #  Fandom     Character     Child
  #  Character  Character     Child
  #  Pairing    Character     Parent
  #  Freeform   Character     Parent
  #  Fandom     Pairing       Child
  #  Character  Pairing       Child
  #  Pairing    Pairing       Child
  #  Freeform   Pairing       Parent

  def add_media(media_id)
    return unless Tag::USER_DEFINED.include?(self.class.name)
    media = Media.find_by_id(media_id)
    return false unless media.is_a? Media
    self.wrangle_parent(media)
  end

  def add_fandom(fandom_id)
    return unless Tag::USER_DEFINED.include?(self.class.name)
    fandom = Fandom.find_by_id(fandom_id)
    return false unless fandom.is_a? Fandom
    self.wrangle_parent(fandom)
  end

  def add_freeform(freeform_id)
    return unless Tag::USER_DEFINED.include?(self.class.name)
    freeform = Freeform.find_by_id(freeform_id)
    return false unless freeform.is_a? Freeform
    freeform.wrangle_parent(self)
  end

  def add_character(character_id)
    return unless Tag::USER_DEFINED.include?(self.class.name)
    character = Character.find_by_id(character_id)
    return false unless character.is_a? Character
    if self.is_a?(Fandom) || self.is_a?(Character)
      character.wrangle_parent(self)
    else
      self.wrangle_parent(character)
    end
  end

  def add_synonym(synonym_id)
    return unless Tag::USER_DEFINED.include?(self.class.name)
    tag = Tag.find_by_id(synonym_id)
    return false unless tag.is_a? Tag
    tag.wrangle_merger(self)
  end

  def update_type(type, admin=false)
    if type=="Ambiguity" || admin
      self.update_attribute("type", type)
    else
      return false
    end
  end

  def update_characters(new=[])
    current = self.characters.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |character_name|
      Character.find_by_name(character_name).remove_from_family(self)
    end
    add.each do |character_name|
      self.add_character(Character.find_by_name(character_name))
    end
  end

  def update_fandoms(new=[])
    current = self.fandoms.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |fandom_name|
      Fandom.find_by_name(fandom_name).remove_from_family(self)
    end
    add.each do |fandom_name|
      self.add_fandom(Fandom.find_by_name(fandom_name))
    end
  end

  def update_medias(new=[])
    current = self.medias.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |media_name|
      Media.find_by_name(media_name).remove_from_family(self)
    end
    add.each do |media_name|
      self.add_media(Media.find_by_name(media_name))
    end
  end

  def update_freeforms(new=[])
    current = self.freeforms.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |freeform_name|
      Freeform.find_by_name(freeform_name).remove_from_family(self)
    end
    add.each do |freeform_name|
      self.add_freeform(Freeform.find_by_name(freeform_name))
    end
  end

  def update_synonyms(new=[])
    current = self.mergers.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |tag_name|
      self.mergers.delete(Tag.find_by_name(tag_name))
    end
    add.each do |tag_name|
      self.add_synonym(Tag.find_by_name(tag_name))
    end
  end

  # return an array of all the common_tags which tagging with self should add
  def common_tags_to_add
    common_tags = []
    common_tags << self.merger
    common_tags << self if self.canonical
    common_tags << self.parents
    common_tags.flatten.uniq.compact
  end

  # methods for counting visible

  def visible_works_count
    if User.current_user && User.current_user.kind_of?(Admin)
      self.works.count(:all,
          :conditions => {:posted => true})
    elsif User.current_user.is_a? User
      self.works.count(:all,
        :conditions => ['works.posted = ? AND (works.hidden_by_admin = ? OR users.id = ?)', true, false, User.current_user.id],
        :joins => "INNER JOIN creatorships ON (creatorships.creation_id = works.id AND creatorships.creation_type = 'Work')
                   INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id
                   INNER JOIN users ON pseuds.user_id = users.id" )
    else
      self.works.count(:all,
          :conditions => {:posted => true, :restricted => false, :hidden_by_admin => false})
    end
  end

  def visible_bookmarks_count
    if User.current_user && User.current_user.kind_of?(Admin)
      conditions = {:private => false}
    elsif User.current_user.is_a? User
      conditions = ['bookmarks.private = ? AND (bookmarks.hidden_by_admin = ? OR bookmarks.user_id = ?)', true, false, User.current_user.id]
    else
      conditions = {:private => false, :hidden_by_admin => false}
    end
    self.bookmarks.count(:all, :conditions => conditions )
  end

  def visible_external_works_count
    if User.current_user && User.current_user.kind_of?(Admin)
      conditions = {}
    else
      conditions = {:hidden_by_admin => false}
    end
    self.external_works.count(:all, :conditions => conditions )
  end

  def visible_taggables_count
    visible_works_count + visible_bookmarks_count + visible_external_works_count
  end

  def possible_children
    type = self[:type]
    return unless type
    fandoms = Fandom.all if type.match /Media|Fandom/
    characters = Character.no_fandom if type.match /Fandom|Character/
    pairings = Pairing.no_fandom if type.match /Fandom|Character|Pairing/
    freeforms = Freeform.no_fandom if type.match /Fandom|Character|Pairing|Freeform/
    fandom = self.fandom
    if fandom.is_a? Fandom
      characters = characters + Character.by_fandom(fandom) if type.match /Fandom|Character/
      pairings = pairings + Pairing.by_fandom(fandom) if type.match /Fandom|Character|Pairing/
      freeforms = freeforms + Freeform.by_fandom(fandom) if type.match /Fandom|Character|Pairing|Freeform/
    end
    hash = {}
    hash['Fandom'] = fandoms.sort - self.children unless fandoms.blank?
    hash['Character'] = characters.sort - self.children unless characters.blank?
    hash['Pairing'] = pairings.sort - self.children unless pairings.blank?
    hash['Freeform'] = freeforms.sort - self.children unless freeforms.blank?
    return hash unless hash.blank?
  end

  def add_fandom_to_parents
    self.parents << self.fandom rescue nil
    return true
  end

  def class_name
    self.class.name
  end

  def ambiguous
    return self if self.is_a?(Ambiguity)
  end

  def unwrangled
    return self unless self.wrangled?
  end
end
