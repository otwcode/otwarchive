class Tag < ActiveRecord::Base

  TYPES = ['Rating', 'Warning', 'Category', 'Media', 'Fandom', 'Pairing', 'Character', 'Genre', 'Freeform']

  has_many :taggings, :as => :tagger
  has_many :works, :through => :taggings, :source => :taggable, :source_type => 'Work'
  has_many :bookmarks, :through => :taggings, :source => :taggable, :source_type => 'Bookmark'
  has_many :tags, :through => :taggings, :source => :taggable, :source_type => 'Tag'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:type]
  validates_length_of :name, :maximum => ArchiveConfig.TAG_MAX, 
                             :message => "is too long -- try using less than #{ArchiveConfig.TAG_MAX} characters or using commas to separate your tags.".t
  validates_format_of :name, 
                      :with => /\A[-a-zA-Z0-9 \/?.!''"":;\|\]\[}{=~!@#\$%^&()_+]+\z/, 
                      :message => "can only be made up of letters, numbers, spaces and basic punctuation, but not commas, asterisks or angle brackets.".t

  def before_validation
    self.name = name.strip.squeeze(" ") if self.name
  end

  named_scope :valid, {:conditions => {:banned => false}}
  named_scope :banned, {:conditions => {:banned => true}}
  named_scope :canonical, {:conditions => {:canonical => true}}
  named_scope :by_popularity, {:order => 'taggings_count DESC'}
  named_scope :ordered_by_name, {:order => 'name ASC'}
  named_scope :unwrangled, {:conditions => {:banned => false, :canonical => false, :canonical_id => nil}}  
  named_scope :by_category, lambda { |*args| {:conditions => ["type IN (?)", args.flatten] }}  
  
  named_scope :on_works, lambda {|tagged_works|
    {
      :select => "DISTINCT tags.*",
      :joins => "INNER JOIN taggings on tags.id = taggings.tagger_id
                  INNER JOIN works ON (works.id = taggings.taggable_id AND taggings.taggable_type = 'Work')",
      :conditions => ['works.id in (?)', tagged_works.collect(&:id)]
    }
  }
  
  named_scope :by_fandom, lambda { |*fandoms|
      if fandoms.compact.blank?
        {:conditions => ["fandom_id IS NULL"] }
      else 
        { :conditions => ["fandom_id IN (?)", fandoms.flatten.map(&:id)] }
      end
  }
  
  def self.string
    all.map(&:name).join(ArchiveConfig.DELIMITER)
  end
  
  def self.count_by_fandom(*fandoms)
    if fandoms.compact.blank?
      self.count(:conditions => ["fandom_id IS NULL"])
    else
      self.count(:conditions => ["fandom_id IN (?)", fandoms.flatten.map(&:id)] )
    end
  end
  
  def self.setup_canonical(name)
    tag = self.find_or_create_by_name(name)
    tag.update_attribute(:canonical, true)
    tag
  end
  
  def self.for_tag_cloud
    freeforms = Freeform.valid.find(:all, :conditions => ["genre_id IS NULL"])
    genres = Genre.valid
    return (freeforms + genres).sort
  end
  
  def unwrangled?
    return false if (self.banned || self.canonical || self.canonical_id)
    return true
  end

  # sort tags by name
  def <=>(another_tag)
    name.downcase <=> another_tag.name.downcase
  end
  
  # find all the tags that point to a canonical tag
  def synonyms
    Tag.find_all_by_canonical_id(self.id)
  end

  # find the canonical tag that a tag points to
  def synonym
    Tag.find(self.canonical_id) if self.canonical_id
  end
  
  # set a tag to redirect to a canonical tag
  def synonym=(tag)
    return false unless tag.canonical?
    return false unless tag[:type] == self[:type]
    self.update_attribute(:canonical_id, tag.id) 
    self.reassign_to_canonical
  end

  # reassign the tags's works and children to its canonical synonym
  def reassign_to_canonical
    return false unless self.synonym.is_a?(self.class)
    for work in self.works
      work.tags.delete(self)
      work.tags << self.synonym unless work.tags.include?(self.synonym)
    end
  end

  def update_fandom
    return if self.is_a? Fandom
    return if self.fandom_id
    fandom = self.works.first.fandoms.first rescue nil
    self.update_attribute(:fandom_id, fandom.id) if fandom
  end

  def fandom
    Fandom.find(self.fandom_id) if fandom_id
  end
  
  
  def update_canonical
    if self.is_a?(Freeform) && self.canonical
      genre_tag = Genre.create_from_freeform(self)
    elsif self.canonical_id
      self.reassign_to_canonical
    end
  end

end
