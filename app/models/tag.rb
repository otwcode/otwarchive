class Tag < ActiveRecord::Base
  
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include StringCleaner

  NAME = "Tag"

  # Note: the order of this array is important.
  # It is the order that tags are shown in the header of a work
  # (banned tags are not shown)
  TYPES = ['Rating', 'Warning', 'Category', 'Media', 'Fandom', 'Relationship', 'Character', 'Freeform', 'Banned' ]

  # these tags can be filtered on
  FILTERS = TYPES - ['Banned', 'Media']

  # these tags show up on works
  VISIBLE = TYPES - ['Media', 'Banned']

  # these are tags which have been created by users
  # the order is important, and it is the order in which they appear in the tag wrangling interface
  USER_DEFINED = ['Fandom', 'Character', 'Relationship', 'Freeform']

  acts_as_commentable
  def commentable_name
    self.name
  end

  # For a tag, the commentable owners are the wranglers of the fandom(s)
  def commentable_owners
    # if the tag is a fandom, grab its wranglers or the wranglers of its canonical merger
    if self.is_a?(Fandom)
      self.canonical? ? self.wranglers : (self.merger_id ? self.merger.wranglers : [])
    # if the tag is any other tag, try to grab all the wranglers of all its parent fandoms, if applicable
    else
      begin
        self.fandoms.collect {|f| f.wranglers}.compact.flatten.uniq
      rescue
        []
      end
    end
  end

  has_many :mergers, :foreign_key => 'merger_id', :class_name => 'Tag'
  belongs_to :merger, :class_name => 'Tag'
  belongs_to :fandom
  belongs_to :media
  belongs_to :last_wrangler, :polymorphic => true

  has_many :filter_taggings, :foreign_key => 'filter_id', :dependent => :destroy
  has_many :filtered_works, :through => :filter_taggings, :source => :filterable, :source_type => 'Work'
  has_one :filter_count, :foreign_key => 'filter_id'
  has_many :direct_filter_taggings,
              :class_name => "FilterTagging",
              :foreign_key => 'filter_id',
              :conditions => "inherited = 0"
  # not used anymore? has_many :direct_filtered_works, :through => :direct_filter_taggings, :source => :filterable, :source_type => 'Work'

  has_many :common_taggings, :foreign_key => 'common_tag_id', :dependent => :destroy
  has_many :child_taggings, :class_name => 'CommonTagging', :as => :filterable
  has_many :children, :through => :child_taggings, :source => :common_tag
  has_many :parents, :through => :common_taggings, :source => :filterable, :source_type => 'Tag', :after_remove => :update_wrangler

  has_many :meta_taggings, :foreign_key => 'sub_tag_id', :dependent => :destroy
  has_many :meta_tags, :through => :meta_taggings, :source => :meta_tag, :before_remove => :update_meta_filters
  has_many :sub_taggings, :class_name => 'MetaTagging', :foreign_key => 'meta_tag_id', :dependent => :destroy
  has_many :sub_tags, :through => :sub_taggings, :source => :sub_tag, :before_remove => :remove_sub_filters
  has_many :direct_meta_tags, :through => :meta_taggings, :source => :meta_tag, :conditions => "meta_taggings.direct = 1"
  has_many :direct_sub_tags, :through => :sub_taggings, :source => :sub_tag, :conditions => "meta_taggings.direct = 1"

  has_many :same_work_tags, :through => :works, :source => :tags, :uniq => true
  has_many :suggested_fandoms, :through => :works, :source => :fandoms, :uniq => true

  has_many :taggings, :as => :tagger
  has_many :works, :through => :taggings, :source => :taggable, :source_type => 'Work'
  has_many :bookmarks, :through => :taggings, :source => :taggable, :source_type => 'Bookmark'
  has_many :external_works, :through => :taggings, :source => :taggable, :source_type => 'ExternalWork'
  has_many :approved_collections, :through => :filtered_works

  has_many :set_taggings, :dependent => :destroy
  has_many :tag_sets, :through => :set_taggings
  has_many :owned_tag_sets, :through => :tag_sets
  
  has_many :tag_set_associations, :dependent => :destroy
  has_many :parent_tag_set_associations, :class_name => 'TagSetAssociation', :foreign_key => 'parent_tag_id', :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :minimum => 1, :message => "cannot be blank."
  validates_length_of :name,
    :maximum => ArchiveConfig.TAG_MAX,
    :message => "of tag is too long -- try using less than #{ArchiveConfig.TAG_MAX} characters or using commas to separate your tags."
  validates_format_of :name,
    :with => /\A[^,*<>^{}=`\\%]+\z/,
    :message => 'of a tag can not include the following restricted characters: , ^ * < > { } = ` \\ %'

  validates_presence_of :sortable_name
    
  validate :unwrangleable_status
  def unwrangleable_status
    if unwrangleable? && (canonical? || merger_id.present?)
      self.errors.add(:unwrangleable, "can't be set on a canonical or synonymized tag.")
    end

    if unwrangleable? && is_a?(UnsortedTag)
      self.errors.add(:unwrangleable, "can't be set on an unsorted tag.")
    end
  end

  before_update :remove_index_for_type_change, if: :type_changed?
  def remove_index_for_type_change
    @destroyed = true
    tire.update_index
  end

  before_validation :check_synonym
  def check_synonym
    if !self.new_record? && self.name_changed?
      # ordinary wranglers can change case and accents but not punctuation or the actual letters in the name
      # admins can change tags with no restriction
      unless User.current_user.is_a?(Admin) || (self.name.downcase == self.name_was.downcase) || (self.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/u,'').downcase.to_s == self.name_was.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/u,'').downcase.to_s)
        self.errors.add(:name, "can only be changed by an admin.")
      end
    end
    if self.merger_id
      if self.canonical?
        self.errors.add(:base, "A canonical can't be a synonym")
      end
      if self.merger_id == self.id
        self.errors.add(:base, "A tag can't be a synonym of itself.")
      end
      unless self.merger.class == self.class
        self.errors.add(:base, "A tag can only be a synonym of a tag in the same category as itself.")
      end
    end
  end

  before_validation :squish_name
  def squish_name
    self.name = name.squish if self.name
  end

  before_validation :set_sortable_name
  def set_sortable_name
    if sortable_name.blank?
      self.sortable_name = remove_articles_from_string(self.name)
    end
  end

  before_save :set_last_wrangler
  def set_last_wrangler
    unless User.current_user.nil?
      self.last_wrangler = User.current_user
    end
  end
  def update_wrangler(tag)
    unless User.current_user.nil?
      self.update_attributes(:last_wrangler => User.current_user)
    end
  end

  before_save :check_type_changes, :if => :type_changed?
  def check_type_changes
    # if the tag used to be a Fandom and is now something else, no parent type will fit, remove all parents
    # if the tag had a type and is now an UnsortedTag, it can't be put into fandoms, so remove all parents
    if self.type_was == "Fandom" || self.type == "UnsortedTag" && !self.type_was.nil?
      self.parents = []
    # if the tag has just become a Fandom, it needs the Uncategorized media added to it manually, and no other parents (the after_save hook on Fandom won't take effect, since it's not a Fandom yet)
    elsif self.type == "Fandom" && !self.type_was.nil?
      self.parents = [Media.uncategorized]
    end
  end

  scope :id_only, select("tags.id")

  scope :canonical, where(:canonical => true)
  scope :noncanonical, where(:canonical => false)
  scope :nonsynonymous, noncanonical.where(:merger_id => nil)
  scope :unfilterable, nonsynonymous.where(:unwrangleable => false)
  scope :unwrangleable, where(:unwrangleable => true)

  # we need to manually specify a LEFT JOIN instead of just joins(:common_taggings or :meta_taggings) here because
  # what we actually need are the empty rows in the results
  scope :unwrangled, joins("LEFT JOIN `common_taggings` ON common_taggings.common_tag_id = tags.id").where("unwrangleable = 0 AND common_taggings.id IS NULL")
  scope :in_use, where("canonical = 1 OR taggings_count > 0")
  scope :first_class, joins("LEFT JOIN `meta_taggings` ON meta_taggings.sub_tag_id = tags.id").where("meta_taggings.id IS NULL")

  # Tags that have sub tags
  scope :meta_tag, joins(:sub_taggings).where("meta_taggings.id IS NOT NULL").group("tags.id")
  # Tags that don't have sub tags
  scope :non_meta_tag, joins(:sub_taggings).where("meta_taggings.id IS NULL").group("tags.id")


  # Complicated query alert!
  # What we're doing here:
  # - we get all the tags of any type used on works (the first two lines of the join)
  # - we then chop that down to only the tags used on works that are tagged with our one given tag
  #   (the last line of the join, and the where clause)
  scope :related_tags_for_all, lambda {|tags|
    joins("INNER JOIN taggings ON (tags.id = taggings.tagger_id)
           INNER JOIN works ON (taggings.taggable_id = works.id AND taggings.taggable_type = 'Work')
           INNER JOIN taggings taggings2 ON (works.id = taggings2.taggable_id AND taggings2.taggable_type = 'Work')").
    where("taggings2.tagger_id IN (?)", tags.collect(&:id)).
    group("tags.id")
  }

  scope :related_tags, lambda {|tag| related_tags_for_all([tag])}

  scope :by_popularity, order('taggings_count DESC')
  scope :by_name, order('sortable_name ASC')
  scope :by_date, order('created_at DESC')
  scope :visible, where('type in (?)', VISIBLE).by_name

  scope :by_pseud, lambda {|pseud|
    joins(:works => :pseuds).
    where(:pseuds => {:id => pseud.id})
  }

  scope :by_type, lambda {|*types| where(types.first.blank? ? "" : {:type => types.first})}
  scope :with_type, lambda {|type| where({:type => type}) }

  # This will return all tags that have one of the given tags as a parent
  scope :with_parents, lambda {|parents|
    joins(:common_taggings).where("filterable_id in (?)", parents.first.is_a?(Integer) ? parents : (parents.respond_to?(:value_of) ? parents.value_of(:id) : parents.collect(&:id)))
  }
  
  scope :with_no_parents,
    joins("LEFT JOIN common_taggings ON common_taggings.common_tag_id = tags.id").
    where("filterable_id IS NULL")

  scope :starting_with, lambda {|letter| where('SUBSTR(name,1,1) = ?', letter)}

  scope :filters_with_count, lambda { |work_ids|
    select("tags.*, count(distinct works.id) as count").
    joins(:filtered_works).
    where("works.id IN (?)", work_ids).
    order(:name).
    group(:id)
  }

  scope :visible_to_all_with_count,
    joins(:filter_count).
    select("tags.*, filter_counts.public_works_count as count").
    where('filter_counts.public_works_count > 0 AND tags.canonical = 1')

  scope :visible_to_registered_user_with_count,
    joins(:filter_count).
    select("tags.*, filter_counts.unhidden_works_count as count").
    where('filter_counts.unhidden_works_count > 0 AND tags.canonical = 1')

  scope :public_top, lambda { |tag_count|
    visible_to_all_with_count.
    limit(tag_count).
    order('filter_counts.public_works_count DESC')
  }

  scope :unhidden_top, lambda { |tag_count|
    visible_to_registered_user_with_count.
    limit(tag_count).
    order('filter_counts.unhidden_works_count DESC')
  }

  scope :popular, (User.current_user.is_a?(Admin) || User.current_user.is_a?(User)) ?
      visible_to_registered_user_with_count.order('filter_counts.unhidden_works_count DESC') :
      visible_to_all_with_count.order('filter_counts.public_works_count DESC')

  scope :random, (User.current_user.is_a?(Admin) || User.current_user.is_a?(User)) ?
    visible_to_registered_user_with_count.order("RAND()") :
    visible_to_all_with_count.order("RAND()")

  scope :with_count, (User.current_user.is_a?(Admin) || User.current_user.is_a?(User)) ?
      visible_to_registered_user_with_count : visible_to_all_with_count

  # a complicated join -- we only want to get the tags on approved, posted works in the collection
  COLLECTION_JOIN =  "INNER JOIN filter_taggings ON ( tags.id = filter_taggings.filter_id )
                      INNER JOIN works ON ( filter_taggings.filterable_id = works.id AND filter_taggings.filterable_type = 'Work')
                      INNER JOIN collection_items ON ( works.id = collection_items.item_id AND collection_items.item_type = 'Work'
                                                       AND works.posted = 1
                                                       AND collection_items.collection_approval_status = '#{CollectionItem::APPROVED}'
                                                       AND collection_items.user_approval_status = '#{CollectionItem::APPROVED}' ) "

  scope :for_collections, lambda {|collections|
    joins(COLLECTION_JOIN).
    where("collection_items.collection_id IN (?)", collections.collect(&:id))
  }

  scope :for_collection, lambda { |collection| for_collections([collection]) }

  scope :for_collections_with_count, lambda { |collections|
    for_collections(collections).
    select("tags.*, count(tags.id) as count").
    group(:id).
    order(:name)
  }

  scope :with_scoped_count, lambda {
    select("tags.*, count(tags.id) as count").
    group(:id)
  }

  scope :by_relationships, lambda {|relationships|
    select("DISTINCT tags.*").
    joins(:children).
    where('children_tags.id IN (?)', relationships.collect(&:id))
  }

  scope :in_challenge, lambda {|collection|
    joins("INNER JOIN set_taggings ON (tags.id = set_taggings.tag_id)
           INNER JOIN tag_sets ON (set_taggings.tag_set_id = tag_sets.id)
           INNER JOIN prompts ON (prompts.tag_set_id = tag_sets.id OR prompts.optional_tag_set_id = tag_sets.id)
           INNER JOIN challenge_signups ON (prompts.challenge_signup_id = challenge_signups.id)").
    where("challenge_signups.collection_id = ?", collection.id)
  }

  scope :requested_in_challenge, lambda {|collection|
    in_challenge(collection).where("prompts.type = 'Request'")
  }

  scope :offered_in_challenge, lambda {|collection|
    in_challenge(collection).where("prompts.type = 'Offer'")
  }
  
  # Resque
  
  @queue = :utilities
  # This will be called by a worker when a job needs to be processed
  def self.perform(id, method, *args)
    find(id).send(method, *args)
  end

  # We can pass this any Tag instance method that we want to run later.
  def async(method, *args)
    if Rails.env.test?
      send(method, *args)
    else
      Resque.enqueue(Tag, id, method, *args)
    end
  end

  # Class methods


  # Get tags that are either above or below the average popularity
  def self.with_popularity_relative_to_average(options = {})
    options.reverse_merge!({:factor => 1, :include_meta => false, :greater_than => false, :names_only => false})
    comparison = "<"
    comparison = ">" if options[:greater_than]

    if options[:include_meta]
      tags = select("#{options[:names_only] ? "tags.name" : "tags.*"}, filter_counts.unhidden_works_count as count").
                  joins(:filter_count).
                  where(:canonical => true).
                  where("filter_counts.unhidden_works_count #{comparison} (select avg(unhidden_works_count) from filter_counts) * ?", options[:factor]).
                  order("count ASC")
    else
      meta_tag_ids = select("DISTINCT tags.id").joins(:sub_taggings).where(:canonical => true)
      non_meta_ids = meta_tag_ids.empty? ? select("tags.id").where(:canonical => true) : select("tags.id").where(:canonical => true).where("id NOT IN (#{meta_tag_ids.collect(&:id).join(',')})")
      tags = non_meta_ids.empty? ? [] :
                select("#{options[:names_only] ? "tags.name" : "tags.*"}, filter_counts.unhidden_works_count as count").
                  joins(:filter_count).
                  where(:canonical => true).
                  where("tags.id IN (#{non_meta_ids.collect(&:id).join(',')})").
                  where("filter_counts.unhidden_works_count #{comparison} (select AVG(unhidden_works_count) from filter_counts where filter_id in (#{non_meta_ids.collect(&:id).join(',')})) * ?", options[:factor]).
                  order("count ASC")
    end
  end
  
  def self.in_prompt_restriction(restriction)
    joins("INNER JOIN set_taggings ON set_taggings.tag_id = tags.id
           INNER JOIN tag_sets ON tag_sets.id = set_taggings.tag_set_id
           INNER JOIN owned_tag_sets ON owned_tag_sets.tag_set_id = tag_sets.id
           INNER JOIN owned_set_taggings ON owned_set_taggings.owned_tag_set_id = owned_tag_sets.id
           INNER JOIN prompt_restrictions ON (prompt_restrictions.id = owned_set_taggings.set_taggable_id AND owned_set_taggings.set_taggable_type = 'PromptRestriction')").
    where("prompt_restrictions.id = ?", restriction.id)           
  end
  
  def self.by_name_without_articles(fieldname = "name")
    fieldname = "name" unless fieldname.match(/^([\w]+\.)?[\w]+$/)
    order("case when lower(substring(#{fieldname} from 1 for 4)) = 'the ' then substring(#{fieldname} from 5)
            when lower(substring(#{fieldname} from 1 for 2)) = 'a ' then substring(#{fieldname} from 3)
            when lower(substring(#{fieldname} from 1 for 3)) = 'an ' then substring(#{fieldname} from 4)
            else #{fieldname}
            end")
  end
  
  def self.in_tag_set(tag_set)
    if tag_set.is_a?(OwnedTagSet)
      joins(:set_taggings).where("set_taggings.tag_set_id = ?", tag_set.tag_set_id)
    else
      joins(:set_taggings).where("set_taggings.tag_set_id = ?", tag_set.id)
    end      
  end
  
  # gives you [parent_name, child_name], [parent_name, child_name], ...  
  def self.parent_names(parent_type = 'fandom')
    joins(:parents).where("parents_tags.type = ?", parent_type.capitalize).
    select("parents_tags.name as parent_name, tags.name as child_name").
    by_name_without_articles("parent_name").
    by_name_without_articles("child_name")
  end
  
  # Because this can be called by a gigantor tag set and all we need are names not objects,
  # we do an end-run around ActiveRecord and just get the results straight from the db, but 
  # we borrow the sql from parent_names above 
  # returns a hash[parent_name] = child_names
  def self.names_by_parent(child_relation, parent_type = 'fandom')
    hash = {}
    results = ActiveRecord::Base.connection.execute(child_relation.parent_names(parent_type).to_sql)
    results.each {|row| hash[row.first] ||= Array.new; hash[row.first] << row.second}
    hash
  end

  # Used for associations, such as work.fandoms.string
  # Yields a comma-separated list of tag names
  def self.string
    all.map{|tag| tag.name}.join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
  end

  # Use the tag name in urls and escape url-unfriendly characters
  def to_param
    # can't find a tag with a name that hasn't been saved yet
    saved_name = self.name_changed? ? self.name_was : self.name
    saved_name.gsub('/', '*s*').gsub('&', '*a*').gsub('.', '*d*').gsub('?', '*q*').gsub('#', '*h*')
  end

  ## AUTOCOMPLETE
  # set up autocomplete and override some methods
  include AutocompleteSource
  def autocomplete_prefixes
    prefixes = [ "autocomplete_tag_#{type.downcase}", "autocomplete_tag_all" ]
    prefixes
  end
  
  def add_to_autocomplete(score = nil)
    score ||= autocomplete_score
    if self.is_a?(Character) || self.is_a?(Relationship)
      parents.each do |parent|
        $redis.zadd("autocomplete_fandom_#{parent.name.downcase}_#{type.downcase}", score, autocomplete_value) if parent.is_a?(Fandom)
      end
    end
    super
  end

  def remove_from_autocomplete
    super
    if self.is_a?(Character) || self.is_a?(Relationship)
      parents.each do |parent|
        $redis.zrem("autocomplete_fandom_#{parent.name.downcase}_#{type.downcase}", autocomplete_value) if parent.is_a?(Fandom)
      end
    end
  end
  
  def remove_stale_from_autocomplete
    super
    if self.is_a?(Character) || self.is_a?(Relationship)
      parents.each do |parent|
        $redis.zrem("autocomplete_fandom_#{parent.name.downcase}_#{type.downcase}", autocomplete_value_was) if parent.is_a?(Fandom)
      end
    end
  end

  def self.parse_autocomplete_value(current_autocomplete_value)
    current_autocomplete_value.split(AUTOCOMPLETE_DELIMITER, 2)
  end
  

  def autocomplete_score
    taggings_count
  end
  
  # look up tags that have been wrangled into a given fandom
  def self.autocomplete_fandom_lookup(options = {})
    options.reverse_merge!({:term => "", :tag_type => "character", :fandom => "", :fallback => true})
    search_param = options[:term]
    tag_type = options[:tag_type]
    fandoms = Tag.get_search_terms(options[:fandom])
      
    # fandom sets are too small to bother breaking up
    # we're just getting ALL the tags in the set(s) for the fandom(s) and then manually matching
    results = []
    fandoms.each do |single_fandom|
      if search_param.blank?
        # just return ALL the characters
        results += $redis.zrevrange("autocomplete_fandom_#{single_fandom}_#{tag_type}", 0, -1)
      else
        search_regex = Tag.get_search_regex(search_param)
        results += $redis.zrevrange("autocomplete_fandom_#{single_fandom}_#{tag_type}", 0, -1).select {|tag| tag.match(search_regex)}
      end
    end
    if options[:fallback] && results.empty? && search_param.length > 0
      # do a standard tag lookup instead
      Tag.autocomplete_lookup(:search_param => search_param, :autocomplete_prefix => "autocomplete_tag_#{tag_type}")
    else
      results
    end
  end
  
  ## END AUTOCOMPLETE



  # Substitute characters that are particularly prone to cause trouble in urls
  def self.find_by_name(string)
    return unless string.is_a? String
    string = string.gsub('*s*', '/').gsub('*a*', '&').gsub('*d*', '.').gsub('*q*', '?').gsub('*h*', '#')
    self.where('name = ?', string).first
  end

  # If a tag by this name exists in another class, add a suffix to disambiguate them
  def self.find_or_create_by_name(new_name)
    if new_name && new_name.is_a?(String)
      new_name.squish!
      tag = Tag.find_by_name(new_name)
      # if the tag exists and has the proper class, or it is an unsorted tag and it can be sorted to the self class
      if tag && (tag.class == self || tag.class == UnsortedTag && tag = tag.recategorize(self.to_s))
        tag
      elsif tag
        self.find_or_create_by_name(new_name + " - " + self.to_s)
      else
        self.create(:name => new_name)
      end
    end
  end

  def self.create_canonical(name, adult=false)
    tag = self.find_or_create_by_name(name)
    raise "how did this happen?" unless tag
    tag.update_attribute(:canonical,true)
    tag.update_attribute(:adult, adult)
    raise "how did this happen?" unless tag.canonical?
    return tag
  end

  # Inherited tag classes can set this to indicate types of tags with which they may have a parent/child
  # relationship (ie. media: parent, fandom: child; fandom: parent, character: child)
  def parent_types
    []
  end
  def child_types
    []
  end

  # Instance methods that are common to all subclasses (may be overridden in the subclass)

  def unwrangled?
    !(self.canonical? || self.unwrangleable? || self.merger_id.present? || self.mergers.any?)
  end

  # sort tags by name
  def <=>(another_tag)
    name.downcase <=> another_tag.name.downcase
  end

  # only allow changing the tag type for unwrangled tags not used in any tag sets or on any works
  def can_change_type?
    self.unwrangled? && self.set_taggings.count == 0 && self.works.count == 0
  end

  # tags having their type changed need to be reloaded to be seen as an instance of the proper subclass
  def recategorize(new_type)
    self.update_attribute(:type, new_type)
    # return a new instance of the tag, with the correct class
    Tag.find(self.id)
  end

  #### FILTERING ####
  
  include WorksOwner  
  # Used in works_controller to determine whether to expire the cache for this tag's works index page
  def works_index_cache_key(tag=nil, index_works=nil)
    index_works ||= self.canonical? ? self.filtered_works : self.works
    super(tag, index_works.where(:posted => true))
  end
    

  # Usage is either:
  # reindex_taggables
  # 
  # or:
  # reindex taggables do 
  #   # some other code
  # end
  #
  # If you use the second method, what will happen is that the ids of the works and 
  # bookmarks that need to be re-indexed for the search engine will first be saved,
  # then the code will be executed, and then the works/bookmarks will be sent off for
  # reindexing. (that's what the "yield" does -- it yields to the block you pass in)
  # 
  # Otherwise, if you removed the works from this tag in the code, you wouldn't have 
  # a way of finding their ids to reindex them. :)
  def reindex_taggables
    work_ids = all_filtered_work_ids
    bookmark_ids = all_bookmark_ids
    yield if block_given?
    reindex_all_works(work_ids)
    reindex_all_bookmarks(bookmark_ids)
  end

  # reindex all works that are tagged with this tag or its subtags or synonyms (the filter_taggings table)
  # if work_ids are passed in, those will be used (eg if we need to save the ids before making changes, then
  # reindex after the changes are done)
  def reindex_all_works(work_ids = [])
    if work_ids.empty? 
      work_ids = all_filtered_work_ids
    end
    RedisSearchIndexQueue.queue_works(work_ids, priority: :low)
  end

  # In the case of works, the filter_taggings table already collects all the things tagged
  # by this tag or its subtags/synonyms
  def all_filtered_work_ids
    # all synned and subtagged works should be under filter taggings
    # add in the direct works for any noncanonical tags    
    (self.filter_taggings.where(:filterable_type => "Work").value_of(:filterable_id) +      
      self.works.value_of(:id)).uniq
  end
  
  # Reindex all bookmarks (bookmark_ids argument works as above)
  def reindex_all_bookmarks(bookmark_ids = [])
    if bookmark_ids.empty?
      bookmark_ids = all_bookmark_ids
    end
    RedisSearchIndexQueue.queue_bookmarks(bookmark_ids, priority: :low)
  end
  
  # We call this to get the ids of all the bookmarks that are tagged by this tag or its subtags
  # We use ids rather than actual bookmark objects to avoid passing around a lot of instantiated AR objects around 
  # Per discussion with TW chair Emilie, I'm limiting depth of the recursion to 10 here so we don't get stuck in some endlessly deep loop
  # That means that if we ever have subtags nested more than 10 deep, the bookmarks will NOT get reindexed but we shouldn't
  # have that much nesting anyway -- current max is 4 we think
  def all_bookmark_ids(depth = 0)
    return [] if depth == 10
    self.bookmarks.value_of(:id) + 
      self.sub_tags.collect {|subtag| subtag.all_bookmark_ids(depth+1)}.flatten + 
      self.mergers.collect {|syn| syn.all_bookmark_ids(depth+1)}.flatten
  end
  
  
  # Add any filter taggings that should exist but don't
  def self.add_missing_filter_taggings
    Tag.find_each(:conditions => "taggings_count != 0 AND (canonical = 1 OR merger_id IS NOT NULL)") do |tag|
      if tag.filter
        to_add = tag.works - tag.filter.filtered_works
        to_add.each do |work|
          tag.filter.filter_taggings.create!(:filterable => work)
        end
      end
    end
  end

  # Add any filter taggings that should exist but don't
  def self.add_missing_filter_taggings
    i = Work.posted.count
    Work.find_each(:conditions => "posted = 1") do |work|
      begin
        should_have = work.tags.collect(&:filter).compact.uniq
        should_add = should_have - work.filters
        unless should_add.empty?
          puts "Fixing work #{i}"
          work.filters = (work.filters + should_add).uniq
        end
      rescue
        puts "Problem with work #{work.id}"
      end
      i = i - 1
    end
  end

  # The version of the tag that should be used for filtering, if any
  def filter
    self.canonical? ? self : ((self.merger && self.merger.canonical?) ? self.merger : nil)
  end

  before_update :update_filters_for_canonical_change
  before_update :update_filters_for_merger_change

  # If a tag was not canonical but is now, it needs new filter_taggings
  # If it was canonical but isn't anymore, we need to change or remove
  # the filter_taggings as appropriate
  def update_filters_for_canonical_change
    if self.canonical_changed?
      if self.canonical?
        self.async(:add_filter_taggings)
      elsif self.merger && self.merger.canonical?
        self.async(:move_filter_taggings_to_merger)
      else
        self.async(:remove_filter_taggings)
      end
    end
  end
  
  # this tag was canonical and now isn't anymore
  # move the filter taggings from this tag to its new synonym and
  # update the search index for the works under this tag and its subtags 
  def move_filter_taggings_to_merger
    # we pass the code to be done to reindex taggables so the work and bookmark ids that will need to be reindexed
    # get saved BEFORE we change the merger in all the filters!
    reindex_taggables do
      self.filter_taggings.update_all(["filter_id = ?", self.merger_id])
    end
    self.async(:reset_filter_count)
  end

  # If a tag has a new merger, add to the filter_taggings for that merger
  # If a tag has a new merger but had an old merger, add new filter_taggings
  # and get rid of the old filter_taggings as appropriate
  def update_filters_for_merger_change
    if self.merger_id_changed?
      # setting the merger_id doesn't update the merger so we do it here
      if self.merger_id
        self.merger = Tag.find_by_id(self.merger_id)
      else
        self.merger = nil
      end
      if self.merger && self.merger.canonical?
        self.async(:add_filter_taggings)
      end
      old_merger = Tag.find_by_id(self.merger_id_was)
      if old_merger && old_merger.canonical?
        self.async(:remove_filter_taggings, old_merger.id)
      end
    end
  end

  # Add filter taggings for a given tag
  # This is currently called only if this tag has just become canonical 
  def add_filter_taggings
    # the "filter" method gets either this tag itself or its merger -- in practice will always be this tag because
    # this method only gets called when this tag is canonical and therefore cannot have a merger
    filter_tag = self.filter
    if filter_tag  && !filter_tag.new_record?
      # we collect tags for resetting count so that it's only done once after we've added all filters to works
      tags_that_need_filter_count_reset = []
      self.works.each do |work|
        if work.filters.include?(filter_tag)
          # If the work filters already included the filter tag (e.g. because the
          # new filter tag is a meta tag of an existing tag) we make sure to set
          # the inheritance to false, since the work is now directly tagged with
          # the filter or one of its synonyms
          ft = work.filter_taggings.where(["filter_id = ?", filter_tag.id]).first
          ft.update_attribute(:inherited, false)
        else
          work.filters << filter_tag
          tags_that_need_filter_count_reset << filter_tag unless tags_that_need_filter_count_reset.include?(filter_tag)
        end
        unless filter_tag.meta_tags.empty?
          filter_tag.meta_tags.each do |m|
            unless work.filters.include?(m)
              work.filter_taggings.create!(:inherited => true, :filter_id => m.id)
              tags_that_need_filter_count_reset << m unless tags_that_need_filter_count_reset.include?(m)
            end
          end
        end
      end
      
      # make sure that all the works and bookmarks under this tag get reindexed
      # for filtering/searching
      async(:reindex_taggables)
      
      tags_that_need_filter_count_reset.each do |tag_to_reset|
        tag_to_reset.reset_filter_count
      end
    end
  end

  # Remove filter taggings for a given tag
  # If an old_filter value is given, remove filter_taggings from it with due regard
  # for potential duplication (ie, works tagged with more than one synonymous tag)
  def remove_filter_taggings(old_filter_id=nil)
    # we're going to have to reindex all the taggables that WERE attached to this work after 
    # we do this
    reindex_taggables do     
      if old_filter_id
        old_filter = Tag.find(old_filter_id)
        # An old merger of a tag needs to be removed
        # This means we remove the old merger itself and all its meta tags unless they
        # should remain because of other existing tags of the work (or because they are
        # also meta tags of the new merger)
        self.works.each do |work|
          filters_to_remove = [old_filter] + old_filter.meta_tags
          filters_to_remove.each do |filter_to_remove|
            if work.filters.include?(filter_to_remove)
              # We collect all sub tags, i.e. the tags that would have the filter_to_remove as
              # meta. If any of these or its mergers (synonyms) are tags of the work, the
              # filter_to_remove remains
              all_sub_tags = filter_to_remove.sub_tags + [filter_to_remove]
              sub_mergers = all_sub_tags.empty? ? [] : all_sub_tags.collect(&:mergers).flatten.compact
              all_tags_with_filter_to_remove_as_meta = all_sub_tags + sub_mergers
              # don't include self because at this point in time (before the save) self
              # is still in the list of submergers from when it was a synonym to the old filter
              remaining_tags = work.tags - [self]
              # instead we add the new merger of self (if there is one) as the relevant one to check
              remaining_tags += [self.merger] unless self.merger.nil?
              if (remaining_tags & all_tags_with_filter_to_remove_as_meta).empty? # none of the remaining tags need filter_to_remove
                work.filters.delete(filter_to_remove)
                filter_to_remove.reset_filter_count
              else # we should keep filter_to_remove, but check if inheritence needs to be updated
                direct_tags_for_filter_to_remove = filter_to_remove.mergers + [filter_to_remove]
                if (remaining_tags & direct_tags_for_filter_to_remove).empty? # not tagged with filter or mergers directly
                  ft = work.filter_taggings.where(["filter_id = ?", filter_to_remove.id]).first
                  ft.update_attribute(:inherited, true)
                end
              end
            end
          end
        end
      else
        self.filter_taggings.destroy_all
        self.reset_filter_count
      end
    end
  end

  # Add filter taggings to this tag's works for one of its meta tags
  def inherit_meta_filters(meta_tag_id)
    meta_tag = Tag.find_by_id(meta_tag_id)
    return unless meta_tag.present?
    self.filtered_works.each do |work|        
      unless work.filters.include?(meta_tag)
        work.filter_taggings.create!(:inherited => true, :filter_id => meta_tag.id)
        RedisSearchIndexQueue.reindex(work, priority: :low)
      end
    end
  end

  def reset_filter_count
    admin_settings = Rails.cache.fetch("admin_settings"){AdminSetting.first}
    unless admin_settings.suspend_filter_counts?
      current_filter = self.filter
      # we only need to cache values for user-defined tags
      # because they're the only ones we access
      if current_filter && (Tag::USER_DEFINED.include?(current_filter.class.to_s))
        attributes = {:public_works_count => current_filter.filtered_works.posted.unhidden.unrestricted.count,
          :unhidden_works_count => current_filter.filtered_works.posted.unhidden.count}
        if current_filter.filter_count
          unless current_filter.filter_count.update_attributes(attributes)
            raise "Filter count error for #{current_filter.name}"
          end
        else
          unless current_filter.create_filter_count(attributes)
            raise "Filter count error for #{current_filter.name}"
          end
        end
      end
    end
  end

  #### END FILTERING ####

  # methods for counting visible

  def visible_works_count
    User.current_user.nil? ? self.works.posted.unhidden.unrestricted.count : self.works.posted.unhidden.count
  end

  def visible_bookmarks_count
    self.bookmarks.is_public.count
  end

  def visible_external_works_count
    self.external_works.count(:all, :conditions => {:hidden_by_admin => false})
  end

  def visible_taggables_count
    visible_works_count + visible_bookmarks_count + visible_external_works_count
  end

  def banned
    self.is_a?(Banned)
  end

  def synonyms
    self.canonical? ? self.mergers : [self.merger] + self.merger.mergers - [self]
  end

  # Add a common tagging association
  # Offloading most of the logic to the inherited tag models
  def add_association(tag)
    self.parents << tag unless self.has_parent?(tag)
  end

  def has_parent?(tag)
    self.common_taggings.where(:filterable_id => tag.id).count > 0
  end
  
  def has_child?(tag)
    self.child_taggings.where(:common_tag_id => tag.id).count > 0
  end

  def associations_to_remove; @associations_to_remove ? @associations_to_remove : []; end
  def associations_to_remove=(taglist)
    taglist.reject {|tid| tid.blank?}.each do |tag_id|
      tag_to_remove = Tag.find(tag_id)
      if tag_to_remove
        self.async(:remove_association, tag_to_remove.id)
      end
    end
  end
  
  # Determine how two tags are related and divorce them from each other
  def remove_association(tag_id)
    tag = Tag.find(tag_id)
    if tag.class == self.class
      if self.mergers.include?(tag)
        tag.update_attributes(:merger_id => nil)
      elsif self.meta_tags.include?(tag)
        self.meta_tags.delete(tag)
      elsif self.sub_tags.include?(tag)
        tag.meta_tags.delete(self)
      end
    else
      if self.parents.include?(tag)
        self.parents.delete(tag)
      elsif tag.parents.include?(self)
        tag.parents.delete(self)
      end
    end
    tag.touch
    self.touch
  end
  
  # Making this asynchronous
  def update_meta_filters(meta_tag)
    async(:remove_meta_filters, meta_tag.id)
  end

  # When a meta tagging relationship is removed, things filter-tagged with the meta tag
  # and the sub tag should have the meta filter-tagging removed unless it's directly tagged
  # with the meta tag or one of its synonyms or a different sub tag of the meta tag or one of its synonyms
  def remove_meta_filters(meta_tag_id)
    meta_tag = Tag.find(meta_tag_id)
    # remove meta tag from this tag's sub tags
    self.sub_tags.each {|sub| sub.meta_tags.delete(meta_tag) if sub.meta_tags.include?(meta_tag)}
    # remove inherited meta tags from this tag and all of its sub tags
    inherited_meta_tags = meta_tag.meta_tags
    inherited_meta_tags.each do |tag|
      self.meta_tags.delete(tag) if self.meta_tags.include?(tag)
      self.sub_tags.each {|sub| sub.meta_tags.delete(tag) if sub.meta_tags.include?(tag)}
    end
    # remove filters for meta tag from this tag's works
    other_sub_tags = meta_tag.sub_tags - ([self] + self.sub_tags)
    self.filtered_works.each do |work|
      to_remove = [meta_tag] + inherited_meta_tags
      to_remove.each do |tag|
        if work.filters.include?(tag) && (work.filters & other_sub_tags).empty?
          unless work.tags.include?(tag) || !(work.tags & tag.mergers).empty?
            work.filters.delete(tag)
            RedisSearchIndexQueue.reindex(work, priority: :low)
          end
        end
      end
    end
  end

  def remove_sub_filters(sub_tag)
    sub_tag.update_meta_filters(self)
  end

  # If we're making a tag non-canonical, we need to update its synonyms and children
  before_update :check_canonical
  def check_canonical
    if self.canonical_changed? && !self.canonical?
      self.async(:remove_canonical_associations)
    elsif self.canonical_changed? && self.canonical?
      self.merger_id = nil
    end
    true
  end
  
  def remove_canonical_associations
    self.mergers.each {|tag| tag.update_attributes(:merger_id => nil) if tag.merger_id == self.id }
    self.children.each {|tag| tag.parents.delete(self) if tag.parents.include?(self) }
    self.sub_tags.each {|tag| tag.meta_tags.delete(self) if tag.meta_tags.include?(self) }
    self.meta_tags.each {|tag| self.meta_tags.delete(tag) if self.meta_tags.include?(tag) }
  end

  attr_reader :media_string, :fandom_string, :character_string, :relationship_string, :freeform_string, :meta_tag_string, :sub_tag_string, :merger_string

  def add_parent_string(tag_string)
    names = tag_string.split(',').map(&:squish)
    names.each do |name|
      parent = Tag.find_by_name(name)
      self.add_association(parent) if parent && parent.canonical?
    end
  end

  def fandom_string=(tag_string); self.add_parent_string(tag_string); end
  def media_string=(tag_string); self.add_parent_string(tag_string); end
  def character_string=(tag_string); self.add_parent_string(tag_string); end
  def relationship_string=(tag_string); self.add_parent_string(tag_string); end
  def freeform_string=(tag_string); self.add_parent_string(tag_string); end
  def meta_tag_string=(tag_string)
    names = tag_string.split(',').map(&:squish)
    names.each do |name|
      parent = self.class.find_by_name(name)
      if parent
        meta_tagging = self.meta_taggings.build(:meta_tag => parent, :direct => true)
        unless meta_tagging.valid? && meta_tagging.save
          self.errors.add(:base, "You attempted to create an invalid meta tagging. :(")
        end
      end
    end
  end

  def sub_tag_string=(tag_string)
    names = tag_string.split(',').map(&:squish)
    names.each do |name|
      sub = self.class.find_by_name(name)
      if sub
        meta_tagging = sub.meta_taggings.build(:meta_tag => self, :direct => true)
        unless meta_tagging.valid? && meta_tagging.save
          self.errors.add(:base, "You attempted to create an invalid meta tagging. :(")
        end
      end
    end
  end

  def syn_string
    self.merger.name if self.merger
  end

  # Make this tag a synonym of another tag -- tag_string is the name of the other tag (which should be canonical)
  # NOTE for potential confusion
  # "merger" is the canonical tag of which this one will be a synonym
  # "mergers" are the tags which are (currently) synonyms of THIS one
  def syn_string=(tag_string)
    if tag_string.blank?
      self.merger_id = nil
    else
      new_merger = Tag.find_by_name(tag_string)
      unless new_merger && new_merger == self.merger
        if new_merger && new_merger == self
          self.errors.add(:base, tag_string + " is considered the same as " + self.name + " by the database.")
        elsif new_merger && !new_merger.canonical?
          self.errors.add(:base, '<a href="/tags/' + new_merger.to_param + '/edit">' + new_merger.name + '</a> is not a canonical tag. Please make it canonical before adding synonyms to it.')
        elsif new_merger && new_merger.class != self.class
          self.errors.add(:base, new_merger.name + " is a #{new_merger.type.to_s.downcase}. Synonyms must belong to the same category.")
        elsif !new_merger
          new_merger = self.class.new(:name => tag_string, :canonical => true)
          unless new_merger.save
            self.errors.add(:base, tag_string + " could not be saved. Please make sure that it's a valid tag name.")
          end
        end
        if new_merger && self.errors.empty?
          self.canonical = false
          self.merger_id = new_merger.id
          async(:add_merger_associations)
        end
      end
    end
  end


  # When we make this tag a synonym of another canonical tag, we want to move all the associations this tag has
  # (subtags, meta tags, etc) over to that canonical tag. 
  # We also need to make sure that the works under those other tags get reindexed
  def add_merger_associations
    # we want to pass this whole block to reindex_taggables so we get the right work_ids 
    reindex_taggables do 
      new_merger = self.merger
      return unless new_merger.present?
      ((self.parents + self.children) - (new_merger.parents + new_merger.children)).each { |tag| new_merger.add_association(tag) }
      if new_merger.is_a?(Fandom)
        (new_merger.medias - self.medias).each {|medium| self.add_association(medium)}
      else
        (new_merger.parents.by_type("Fandom").canonical - self.fandoms).each {|fandom| self.add_association(fandom)}
      end
      self.meta_tags.each { |tag| new_merger.meta_tags << tag unless new_merger.meta_tags.include?(tag) }
      self.sub_tags.each { |tag| tag.meta_tags << new_merger unless tag.meta_tags.include?(new_merger) }
      self.mergers.each {|m| m.update_attributes(:merger_id => new_merger.id)}
      self.children = []
      self.meta_tags = []
      self.sub_tags = []
    end
  end
  
  def merger_string=(tag_string)
    names = tag_string.split(',').map(&:squish)
    names.each do |name|
      syn = Tag.find_by_name(name)
      if syn && !syn.canonical?
        syn.update_attributes(:merger_id => self.id)
        if syn.is_a?(Fandom)
          syn.medias.each {|medium| self.add_association(medium)}
          self.medias.each {|medium| syn.add_association(medium)}
        else
          syn.parents.by_type("Fandom").canonical.each {|fandom| self.add_association(fandom)}
          self.parents.by_type("Fandom").canonical.each {|fandom| syn.add_association(fandom)}
        end
      end
    end
  end

  def indirect_bookmarks(rec=false)
    cond = rec ? {:rec => true, :private => false, :hidden_by_admin => false} : {:private => false, :hidden_by_admin => false}
    work_bookmarks = Bookmark.find(:all, :conditions => {:bookmarkable_id => self.work_ids, :bookmarkable_type => 'Work'}.merge(cond))
    ext_work_bookmarks = Bookmark.find(:all, :conditions => {:bookmarkable_id => self.external_work_ids, :bookmarkable_type => 'ExternalWork'}.merge(cond))
    series_bookmarks = [] # can't tag a series directly? # Bookmark.find(:all, :conditions => {:bookmarkable_id => self.series_ids, :bookmarkable_type => 'Series'}.merge(cond))
    (work_bookmarks + ext_work_bookmarks + series_bookmarks)
  end
  
  #################################
  ## SEARCH #######################
  #################################


  mapping do
    indexes :id,           :index    => :not_analyzed
    indexes :name,         :analyzer => 'snowball', :boost => 100
    indexes :type
    indexes :canonical,    :type     => :boolean
  end
  
  def self.search(options={})
    tire.search(page: options[:page], per_page: 50, type: nil, load: true) do
      query do
        boolean do
          must { string options[:name], default_operator: "AND" } if options[:name].present?
          must { term '_type', options[:type].downcase } if options[:type].present?
          must { term :canonical, 'T' } if options[:canonical].present?
        end
      end
    end
  end  

end

