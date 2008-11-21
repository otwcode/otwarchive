class Tag < ActiveRecord::Base

  # Note: the order of this array is important.
  # 1) It is the order that tags are shown in the header of a work (ambiguous tags are grouped with freeform tags)
  # 2) In a group of tags to be renamed, the tag with the type that comes first keeps its name
  TYPES = ['Rating', 'Warning', 'Category', 'Media', 'Fandom', 'Pairing', 'Character', 'Freeform', 'Ambiguity', 'Banned' ]
  
  # these tags can be filtered on
  FILTERS = TYPES - ['Ambiguity', 'Banned']
  
  # these tags show up on works
  VISIBLE = TYPES - ['Media', 'Banned']

  # these tags can be created by users
  USER_DEFINED = ['Fandom', 'Pairing', 'Character', 'Freeform']

  # these tags can be parents
  PARENTS = USER_DEFINED + ['Media']

  has_many :mergers, :foreign_key => 'merger_id', :class_name => 'Tag'
  belongs_to :merger, :class_name => 'Tag'
  belongs_to :fandom
  belongs_to :media

  has_many :common_tags, :foreign_key => 'common_id'
  has_many :parents, :through => :common_tags, :source => :filterable, :source_type => 'Tag'
  has_many :ambiguities, :through => :common_tags, :source => :filterable, :source_type => 'Ambiguity'
  has_many :filtered_works, :through => :common_tags, :source => :filterable, :source_type => 'Work'
  
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
  
  named_scope :canonical, {:conditions => {:canonical => true}}
  named_scope :unwrangled, {:conditions => {:wrangled => false}}
  named_scope :visible, {:conditions => ['type in (?)', VISIBLE] }

  named_scope :by_popularity, {:order => 'taggings_count DESC'}
  named_scope :by_name, {:order => 'name ASC'}
  
  named_scope :by_fandom, lambda{|fandom| {:conditions => {:fandom_id => fandom.id}}}

  # Class methods
  
  def self.string
    all.map(&:name).join(ArchiveConfig.DELIMITER)
  end
    
  def self.find_or_create_by_name(string)
    return if !string.is_a?(String) || string.blank?
    string.squish!
    type_name = self.name
    tag = Tag.find_by_name_and_type(string, type_name)
    return tag if tag
    classed_tag = find_by_name(string + " - " + self.name)
    return classed_tag if classed_tag
    begin
      tag = self.create!(:name => string)
    rescue ActiveRecord::RecordInvalid # duplicate name in another category
      new_tag = self.create(:name => string + " - " + self.name) # create classed_tag
      # make sure classless tag is ambiguous
      while tag = Tag.find_by_name(string)
        return new_tag if tag.is_a?(Ambiguity) #it was, i can stop
        # change the original one to have the category attached 
        tag.update_attribute(:name, string + " - " + tag.class.name)
      end
      # and create a new Ambiguity tag for the classless name
      Ambiguity.create!(:name => string)
      return new_tag
    end
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
  
  # name without suffix for display when already categorized
  def classless_name
    regexp = Regexp.new(" - " + self.class.name)
    return name unless self.name.match(regexp)
    return name.sub(regexp, "")
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
    self.common_tags.clear
    self.update_common_tags if update_works
  end
    
  def wrangle_ambiguous(update_works=true)
    self.update_attribute(:type, "Ambiguity")
    self.common_tags.clear if update_works
    self.update_common_tags if update_works
  end
    
  def wrangle_canonical(update_works=true)
    self.update_attribute(:canonical, true)
    self.update_attribute(:merger_id, nil)
    self.update_common_tags if update_works
  end
  
  def wrangle_not_canonical(update_works=true)
    self.update_attribute(:canonical, false)
    self.common_tags.clear if update_works
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

  def children
    tags = []
    tags << CommonTag.find_all_by_filterable_id(self.id).map(&:common).uniq.compact.sort
    tags << Fandom.find_all_by_media_id(self.id) if self.is_a?(Media)
    tags << Tag.find_all_by_fandom_id(self.id) if self.is_a?(Fandom)
    tags.flatten.uniq.compact
  end

  def can_be_parent?
    PARENTS.include?(self.class.name)
  end

  def wrangle_parent(parent, update_works=true)
    return unless parent.is_a?(Tag)
    return unless parent.can_be_parent? && parent.canonical?
    self.parents << parent rescue nil
    self.update_common_tags if update_works
  end

  # just parents and grandparents for now. 
  # eventually should traverse the entire branch
  def ancestors
    ancestors = []
    parents = self.parents
    ancestors << parents
    parents.each do |p|
      ancestors << p.parents
    end
    ancestors.flatten.uniq.compact
  end
  
  # return an array of all the common_tags which tagging with self should add
  def common_tags_to_add
    common_tags = []
    common_tags << self.merger
    common_tags << self if self.canonical
    common_tags << self.ancestors
    common_tags.flatten.uniq.compact
  end

  # methods for counting visible

  def visible_works_count
    if User.current_user && User.current_user.kind_of?(Admin)
      conditions = {:posted => true}
    elsif User.current_user.is_a? User
      conditions = ['works.posted = ? AND (works.hidden_by_admin = ? OR users.id = ?)', true, false, User.current_user.id]
    else
      conditions = {:posted => true, :restricted => false, :hidden_by_admin => false}
    end
    self.works.count(:all,
        :conditions => conditions,
        :joins => "INNER JOIN creatorships ON (creatorships.creation_id = works.id AND creatorships.creation_type = 'Work')
                   INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id
                   INNER JOIN users ON pseuds.user_id = users.id" )
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
  
  def possible_children(fandom)
    type = self[:type]
    return unless type
    fandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME) unless fandom.is_a?(Fandom)
    fandoms = Fandom.unwrangled if type.match /Media|Fandom/
    characters = (Character.unwrangled + Character.by_fandom(fandom)).sort if type.match /Fandom|Character/
    pairings = (Pairing.unwrangled + Pairing.by_fandom(fandom)).sort if type.match /Fandom|Character|Pairing/
    freeforms = (Freeform.unwrangled + Freeform.by_fandom(fandom)).sort if type.match /Fandom|Character|Pairing|Freeform/
    hash = {}
    hash['Fandom'] = fandoms - self.children unless fandoms.blank?
    hash['Character'] = characters - self.children unless characters.blank?
    hash['Pairing'] = pairings - self.children unless pairings.blank?
    hash['Freeform'] = freeforms - self.children unless freeforms.blank?
    return hash unless hash.blank?
  end

  def add_fandom_to_parents
    self.parents << self.fandom rescue nil
    return true
  end
  
  def class_name
    self.class.name
  end
end
