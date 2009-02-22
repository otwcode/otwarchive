class Tag < ActiveRecord::Base

  # Note: the order of this array is important.
  # It is the order that tags are shown in the header of a work
  # (ambiguous tags are grouped with freeform tags)
  # (banned tags are not shown)
  TYPES = ['Rating', 'Warning', 'Category', 'Media', 'Fandom', 'Pairing', 'Character', 'Freeform', 'Ambiguity', 'Banned' ]

  # these tags can be filtered on
  FILTERS = TYPES - ['Banned', 'Media']

  # these tags show up on works
  VISIBLE = TYPES - ['Media', 'Banned']

  # these are tags which have been created by users
  USER_DEFINED = ['Fandom', 'Pairing', 'Character', 'Freeform', 'Ambiguity']

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
  named_scope :unwrangled, {:conditions => {:canonical => false, :merger_id => nil}, :order => 'name ASC'}
  named_scope :visible, {:conditions => ['type in (?)', VISIBLE], :order => 'name ASC' }

  named_scope :by_popularity, {:order => 'taggings_count DESC'}
  named_scope :by_name, {:order => 'name ASC'}

  named_scope :by_fandom, lambda{|fandom| {:conditions => {:fandom_id => fandom.id}}}
  named_scope :no_parent, :conditions => {:fandom_id => nil}

  # enigel Feb 09
  named_scope :starting_with, lambda {|letter|
    {
      :conditions => ['SUBSTR(name,1,1) = ?', letter]
    }
  }

  # Class methods

  def self.string
    all.map(&:name).join(ArchiveConfig.DELIMITER)
  end

  def to_param
    name
  end

  def self.find_or_create_by_name(string)
    return if !string.is_a?(String) || string.blank?
    string.squish!
    # try to find the tag
    tag = self.find_by_name(string)
    return tag if tag
    # try to create the tag
    tag = self.create(:name => string) rescue nil
    return tag if tag.andand.valid?
    # it wasn't valid, which probably means it already exists in another category
    old_tag = Tag.find_by_name(string)
    if old_tag # so create this one with the category appended
      new_tag = self.find_or_create_by_name(string + " - " + self.to_s)
      return new_tag if new_tag
    else
      # other tag validation errors - wasn't saved
      return tag
    end
  end

  def self.for_tag_cloud
    Freeform.find(:all, :conditions => {:fandom_id => Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME).id, :merger_id => nil}).sort
  end

  # Instance methods that are common to all subclasses (may be overridden in the subclass)

  # sort tags by name
  def <=>(another_tag)
    name.downcase <=> another_tag.name.downcase
  end


  def update_common_tags
    self.works.each do |work|
      work.update_common_tags
    end
  end

  def wrangle_canonical(update_works=true)
    self.update_attribute(:canonical, true)
    self.update_common_tags if update_works
  end

  def wrangle_not_canonical(update_works=true)
    self.update_attribute(:canonical, false)
    self.update_common_tags if update_works
  end

  def wrangle_merger(merger, update_works=true)
    return unless merger.canonical? && merger.is_a?(self.class)
    self.update_attribute(:merger_id, merger.id)
    self.mergers.each do |synonym|
      synonym.wrangle_merger(merger)
      synonym.add_fandom(self.fandom)
      synonym.add_media(self.media)
    end
    self.add_fandom(merger.fandom)
    self.add_media(merger.media)
    self.update_common_tags if update_works
  end

  def wrangle_parent(parent, update_works=true)
    return unless parent.is_a?(Tag) && parent.canonical?
    self.parents << parent rescue nil
    self.add_fandom(parent.fandom)
    self.add_media(parent.media)
    self.update_common_tags if update_works
  end

  # all tags which have given tag as a parent
  def children
    CommonTagging.find_all_by_filterable_id_and_filterable_type(self.id, 'Tag').map(&:common_tag).uniq.compact.sort
  end

  # parents children and self
  def family
    [self] + self.children + self.parents + self.mergers + [self.merger]
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

  def add_parent_by_id(parent_id)
    if self.is_a?(Fandom)
      add_media(Media.find_by_id(parent_id))
    elsif Tag::USER_DEFINED.include?(self[:type])
      add_fandom(Fandom.find_by_id(parent_id))
    end
  end

  def add_disambiguator(tag)
    return unless self.is_a?(Ambiguity)
    return false unless tag.is_a? Tag
    tag.ambiguities << self
  end
  def remove_disambiguator(tag)
    return unless self.is_a?(Ambiguity)
    return false unless tag.is_a? Tag
    tag.ambiguities.delete(self)
  end

  def add_media(media)
    return unless self.is_a?(Fandom)
    return false unless media.is_a? Media
    self.update_attribute(:media_id, media.id)
    self.wrangle_parent(media)
    nomedia = Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)
    if media != nomedia
      self.remove_media(nomedia) if self.medias.include?(nomedia)
    end
  end
  def remove_media(media)
    return unless self.is_a?(Fandom)
    return false unless media.is_a? Media
    remaining = self.medias - [media]
    self.parents.delete(media)
    if self.media == media
      new_media = remaining.first
      new_media = Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME) unless new_media
      self.add_media(new_media)
    end
  end

  def add_fandom(fandom)
    return unless Tag::USER_DEFINED.include?(self[:type])
    return false unless fandom.is_a? Fandom
    self.update_attribute(:fandom_id, fandom.id)
    self.wrangle_parent(fandom)
    nofandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
    if fandom != nofandom
      self.remove_fandom(nofandom) if self.fandoms.include?(nofandom)
    end
  end

  def remove_fandom(fandom)
    return unless Tag::USER_DEFINED.include?(self[:type])
    return false unless fandom.is_a? Fandom
    remaining = self.fandoms - [fandom]
    self.parents.delete(fandom)
    if self.fandom == fandom
      new_fandom = remaining.first
      new_fandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME) unless new_fandom
      self.add_fandom(new_fandom)
    end
  end

  def add_freeform(freeform)
    return unless Tag::USER_DEFINED.include?(self[:type])
    return false unless freeform.is_a? Freeform
    freeform.wrangle_parent(self)
  end
  def remove_freeform(freeform)
    return unless Tag::USER_DEFINED.include?(self[:type])
    return false unless freeform.is_a? Freeform
    freeform.parents.delete(self)
  end

  def add_pairing(pairing)
    return unless Tag::USER_DEFINED.include?(self[:type])
    return false unless pairing.is_a? Pairing
    if self.is_a?(Freeform)
      self.wrangle_parent(pairing)
    else
      pairing.wrangle_parent(self)
    end
    if self.is_a?(Character)
      pairing.update_attribute(:has_characters, true)
    end
  end
  def remove_pairing(pairing)
    return unless Tag::USER_DEFINED.include?(self[:type])
    return false unless pairing.is_a? Pairing
    if self.is_a?(Freeform)
      self.parents.delete(pairing)
    else
      pairing.parents.delete(self)
    end
    if self.is_a?(Character)
      pairing.update_attribute(:has_characters, false) if pairing.characters.blank?
    end
  end

  def add_character(character)
    return unless Tag::USER_DEFINED.include?(self[:type])
    return false unless character.is_a? Character
    if self.is_a?(Fandom) || self.is_a?(Character)
      character.wrangle_parent(self)
    else
      self.wrangle_parent(character)
    end
    if self.is_a?(Pairing)
      self.update_attribute(:has_characters, true)
    end
  end
  def remove_character(character)
    return unless Tag::USER_DEFINED.include?(self[:type])
    return false unless character.is_a? Character
    if self.is_a?(Fandom) || self.is_a?(Character)
      character.parents.delete(self)
    else
      self.parents.delete(character)
    end
    if self.is_a?(Pairing)
      self.update_attribute(:has_characters, false) if self.characters.blank?
    end
  end

  def add_synonym(synonym)
    return false unless synonym.is_a?(self.class)
    synonym.wrangle_merger(self)
  end
  def remove_synonym(synonym)
    return false unless synonym.is_a?(self.class)
    self.mergers.delete(synonym)
  end

  def update_type(type, admin=false)
    if type=="Ambiguity" || admin
      self.update_attribute("type", type)
    else
      return false
    end
  end

  def update_disambiguators(new=[])
    return unless self[:type] == 'Ambiguity'
    current = self.disambiguators.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |disambiguator_name|
      self.remove_disambiguator(Tag.find_by_name(disambiguator_name))
    end
    add.each do |disambiguator_name|
      self.add_disambiguator(Tag.find_by_name(disambiguator_name))
    end
    disambiguators
  end

  def update_characters(new=[])
    return unless Tag::USER_DEFINED.include?(self[:type])
    current = self.characters.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |character_name|
      self.remove_character(Character.find_by_name(character_name))
    end
    add.each do |character_name|
      self.add_character(Character.find_by_name(character_name))
    end
    characters
  end

  def update_pairings(new=[])
    return unless Tag::USER_DEFINED.include?(self[:type])
    current = self.pairings.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |pairing_name|
      self.remove_pairing(Pairing.find_by_name(pairing_name))
    end
    add.each do |pairing_name|
      self.add_pairing(Pairing.find_by_name(pairing_name))
    end
    pairings
  end

  def update_fandoms(new=[])
    return unless Tag::USER_DEFINED.include?(self[:type])
    current = self.fandoms.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |fandom_name|
      self.remove_fandom(Fandom.find_by_name(fandom_name))
    end
    add.each do |fandom_name|
      self.add_fandom(Fandom.find_by_name(fandom_name))
    end
    if self.fandoms == []
      new_fandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME) unless new_fandom
      self.add_fandom(new_fandom)
    end
    fandoms
  end

  def update_medias(new=[])
    return unless Tag::USER_DEFINED.include?(self[:type])
    current = self.medias.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |media_name|
      self.remove_media(Media.find_by_name(media_name))
    end
    add.each do |media_name|
      self.add_media(Media.find_by_name(media_name))
    end
    if self.medias == []
      new_media = Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME) unless new_media
      self.add_media(new_media)
    end
    medias
  end

  def update_freeforms(new=[])
    return unless Tag::USER_DEFINED.include?(self[:type])
    current = self.freeforms.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |freeform_name|
      self.remove_freeform(Freeform.find_by_name(freeform_name))
    end
    add.each do |freeform_name|
      self.add_freeform(Freeform.find_by_name(freeform_name))
    end
    freeforms
  end

  def update_synonyms(new=[])
    current = self.mergers.map(&:name)
    current = [] unless current
    new = [] unless new
    remove = current - new
    add = new - current
    remove.each do |tag_name|
      self.remove_synonym(Tag.find_by_name(tag_name))
    end
    add.each do |tag_name|
      self.add_synonym(Tag.find_by_name(tag_name))
    end
    mergers
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

  def banned
    return self if self.is_a?(Banned)
  end

  def ambiguous
    return self if self.is_a?(Ambiguity)
  end

  def unwrangled
    return self unless (self.canonical || self.merger || ['Ambiguity', 'Banned'].include?(self.class) )
  end

  def find_similar
    Tag.find(:all, :conditions => ["name like ? and canonical = ?", "%" + self.name + "%", true])
  end

end
