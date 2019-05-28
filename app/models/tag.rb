class Tag < ApplicationRecord

  include ActiveModel::ForbiddenAttributesProtection
  include Searchable
  include StringCleaner
  include WorksOwner

  NAME = "Tag"

  # Note: the order of this array is important.
  # It is the order that tags are shown in the header of a work
  # (banned tags are not shown)
  TYPES = ['Rating', 'ArchiveWarning', 'Category', 'Media', 'Fandom', 'Relationship', 'Character', 'Freeform', 'Banned' ]

  # these tags can be filtered on
  FILTERS = TYPES - ['Banned', 'Media']

  # these tags show up on works
  VISIBLE = TYPES - ['Media', 'Banned']

  # these are tags which have been created by users
  # the order is important, and it is the order in which they appear in the tag wrangling interface
  USER_DEFINED = ['Fandom', 'Character', 'Relationship', 'Freeform']

  def self.label_name
    to_s.pluralize
  end

  delegate :document_type, to: :class

  def document_json
    TagIndexer.new({}).document(self)
  end

  def self.write_redis_to_database
    batch_size = ArchiveConfig.TAG_UPDATE_BATCH_SIZE
    REDIS_GENERAL.smembers("tag_update").each_slice(batch_size) do |batch|
      Tag.transaction do
        batch.each do |id|
          value = REDIS_GENERAL.get("tag_update_#{id}_value")
          sql = []
          sql.push("taggings_count_cache = #{value}") unless value.blank?
          Tag.where(id: id).update_all(sql.join(",")) unless sql.empty?
        end
        REDIS_GENERAL.srem("tag_update", batch)
      end
    end
  end

  def self.taggings_count_expiry(count)
    # What we are trying to do here is work out a resonable amount of time for a work to be cached for
    # This should take the number of taggings and divide it by TAGGINGS_COUNT_CACHE_DIVISOR  ( defaults to 1500 )
    # such that for example 1500, would be naturally be tagged for one minute while 105,000 would be cached for
    # 70 minutes. However we then apply a filter such that the minimum amount of time we will cache something for
    # would be TAGGINGS_COUNT_MIN_TIME ( defaults to 3 minutes ) and the maximum amount of time would be
    # TAGGINGS_COUNT_MAX_TIME ( defaulting to an hour ).
    expiry_time = count / (ArchiveConfig.TAGGINGS_COUNT_CACHE_DIVISOR || 1500)
    [[expiry_time, (ArchiveConfig.TAGGINGS_COUNT_MIN_TIME || 3)].max, (ArchiveConfig.TAGGINGS_COUNT_MAX_TIME || 50) + count % 20 ].min
  end

  def taggings_count_cache_key
    "/v1/taggings_count/#{id}"
  end

  def write_taggings_to_redis(value)
    REDIS_GENERAL.sadd("tag_update", id)
    REDIS_GENERAL.set("tag_update_#{id}_value", value)
    value
  end

  def taggings_count=(value)
    expiry_time = Tag.taggings_count_expiry(value)
    # Only write to the cache if there are more than a number of uses.
    Rails.cache.write(taggings_count_cache_key, value, race_condition_ttl: 10, expires_in: expiry_time.minutes) if value >= ArchiveConfig.TAGGINGS_COUNT_MIN_CACHE_COUNT
    write_taggings_to_redis(value)
  end

  def taggings_count
    cache_read = Rails.cache.read(taggings_count_cache_key)
    return cache_read unless cache_read.nil?
    real_value = taggings.count
    self.taggings_count = real_value
    real_value
  end

  def update_tag_cache
    cache_read = Rails.cache.read(taggings_count_cache_key)
    taggings_count if cache_read.nil? || (cache_read < ArchiveConfig.TAGGINGS_COUNT_MIN_CACHE_COUNT)
  end

  def update_counts_cache(id)
    tag = Tag.find(id)
    tag.taggings_count = tag.taggings.count
  end

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

  attr_accessor :fix_taggings_count

  has_many :mergers, foreign_key: 'merger_id', class_name: 'Tag'
  belongs_to :merger, class_name: 'Tag'
  belongs_to :fandom
  belongs_to :media
  belongs_to :last_wrangler, polymorphic: true

  has_many :filter_taggings, foreign_key: 'filter_id', dependent: :destroy
  has_many :filtered_works, through: :filter_taggings, source: :filterable, source_type: 'Work'
  has_many :filtered_external_works, through: :filter_taggings, source: :filterable, source_type: "ExternalWork"
  has_one :filter_count, foreign_key: 'filter_id'
  has_many :direct_filter_taggings,
              -> { where(inherited: 0) },
              class_name: "FilterTagging",
              foreign_key: 'filter_id'

  # not used anymore? has_many :direct_filtered_works, through: :direct_filter_taggings, source: :filterable, source_type: 'Work'

  has_many :common_taggings, foreign_key: 'common_tag_id', dependent: :destroy
  has_many :child_taggings, class_name: 'CommonTagging', as: :filterable
  has_many :children, through: :child_taggings, source: :common_tag
  has_many :parents,
           through: :common_taggings,
           source: :filterable,
           source_type: 'Tag',
           before_remove: :destroy_common_tagging,
           after_remove: :update_wrangler

  has_many :meta_taggings, foreign_key: 'sub_tag_id', dependent: :destroy
  has_many :meta_tags, through: :meta_taggings, source: :meta_tag, before_remove: :update_meta_filters
  has_many :sub_taggings, class_name: 'MetaTagging', foreign_key: 'meta_tag_id', dependent: :destroy
  has_many :sub_tags, through: :sub_taggings, source: :sub_tag, before_remove: :remove_sub_filters
  has_many :direct_meta_tags, -> { where('meta_taggings.direct = 1') }, through: :meta_taggings, source: :meta_tag
  has_many :direct_sub_tags, -> { where('meta_taggings.direct = 1') }, through: :sub_taggings, source: :sub_tag
  has_many :taggings, as: :tagger
  has_many :works, through: :taggings, source: :taggable, source_type: 'Work'

  has_many :bookmarks, through: :taggings, source: :taggable, source_type: 'Bookmark'
  has_many :external_works, through: :taggings, source: :taggable, source_type: 'ExternalWork'
  has_many :approved_collections, through: :filtered_works

  # TODO Update favorite_tags for this tag_id when a canonical tag becomes a synonym of a new canonical tag
  has_many :favorite_tags, dependent: :destroy

  has_many :set_taggings, dependent: :destroy
  has_many :tag_sets, through: :set_taggings
  has_many :owned_tag_sets, through: :tag_sets

  has_many :tag_set_associations, dependent: :destroy
  has_many :parent_tag_set_associations, class_name: 'TagSetAssociation', foreign_key: 'parent_tag_id', dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, minimum: 1, message: "cannot be blank."
  validates_length_of :name,
    maximum: ArchiveConfig.TAG_MAX,
    message: "of tag is too long -- try using less than #{ArchiveConfig.TAG_MAX} characters or using commas to separate your tags."
  validates_format_of :name,
    with: /\A[^,*<>^{}=`\\%]+\z/,
    message: 'of a tag cannot include the following restricted characters: , &#94; * < > { } = ` \\ %'

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

  after_commit :queue_flush_work_cache
  def queue_flush_work_cache
    async(:flush_work_cache)
  end

  def flush_work_cache
    self.work_ids.each do |work|
      Work.expire_work_tag_groups_id(work)
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
      self.update_attributes(last_wrangler: User.current_user)
    end
  end

  after_save :check_type_changes, if: :saved_change_to_type?
  def check_type_changes
    return if type_before_last_save.nil?

    retyped = Tag.find(self.id)

    # Clean up invalid CommonTaggings.
    retyped.common_taggings.destroy_invalid
    retyped.child_taggings.destroy_invalid

    # If the tag has just become a Fandom, it needs the Uncategorized media
    # added to it manually (the after_save hook on Fandom won't take effect,
    # since it's not a Fandom yet)
    retyped.add_media_for_uncategorized if retyped.is_a?(Fandom)
  end

  # Callback for has_many :parents.
  # Destroy the common tagging so we trigger CommonTagging's callbacks when a
  # parent is removed. We're specifically interested in the update_search
  # callback that will reindex the tag and return it to the unwrangled bin.
  def destroy_common_tagging(parent)
    self.common_taggings.find_by(filterable_id: parent.id).try(:destroy)
  end

  scope :id_only, -> { select("tags.id") }

  scope :canonical, -> { where(canonical: true) }
  scope :noncanonical, -> { where(canonical: false) }
  scope :nonsynonymous, -> { noncanonical.where(merger_id: nil) }
  scope :synonymous, -> { noncanonical.where("merger_id IS NOT NULL") }
  scope :unfilterable, -> { nonsynonymous.where(unwrangleable: false) }
  scope :unwrangleable, -> { where(unwrangleable: true) }

  # we need to manually specify a LEFT JOIN instead of just joins(:common_taggings or :meta_taggings) here because
  # what we actually need are the empty rows in the results
  scope :unwrangled, -> { joins("LEFT JOIN `common_taggings` ON common_taggings.common_tag_id = tags.id").where("unwrangleable = 0 AND common_taggings.id IS NULL") }
  scope :in_use, -> { where("canonical = 1 OR taggings_count_cache > 0") }
  scope :first_class, -> { joins("LEFT JOIN `meta_taggings` ON meta_taggings.sub_tag_id = tags.id").where("meta_taggings.id IS NULL") }

  # Tags that have sub tags
  scope :meta_tag, -> { joins(:sub_taggings).where("meta_taggings.id IS NOT NULL").group("tags.id") }
  # Tags that don't have sub tags
  scope :non_meta_tag, -> { joins(:sub_taggings).where("meta_taggings.id IS NULL").group("tags.id") }


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

  scope :by_popularity, -> { order('taggings_count_cache DESC') }
  scope :by_name, -> { order('sortable_name ASC') }
  scope :by_date, -> { order('created_at DESC') }
  scope :visible, -> { where('type in (?)', VISIBLE).by_name }

  scope :by_pseud, lambda {|pseud|
    joins(works: :pseuds).
    where(pseuds: {id: pseud.id})
  }

  scope :by_type, lambda {|*types| where(types.first.blank? ? "" : {type: types.first})}
  scope :with_type, lambda {|type| where({type: type}) }

  # This will return all tags that have one of the given tags as a parent
  scope :with_parents, lambda {|parents|
    joins(:common_taggings).where("filterable_id in (?)", parents.first.is_a?(Integer) ? parents : (parents.respond_to?(:pluck) ? parents.pluck(:id) : parents.collect(&:id)))
  }

  scope :with_no_parents, -> {
    joins("LEFT JOIN common_taggings ON common_taggings.common_tag_id = tags.id").
    where("filterable_id IS NULL")
  }

  scope :starting_with, lambda {|letter| where('SUBSTR(name,1,1) = ?', letter)}

  scope :filters_with_count, lambda { |work_ids|
    select("tags.*, count(distinct works.id) as count").
    joins(:filtered_works).
    where("works.id IN (?)", work_ids).
    order(:name).
    group(:id)
  }

  scope :visible_to_all_with_count, -> {
    joins(:filter_count).
    select("tags.*, filter_counts.public_works_count as count").
    where('filter_counts.public_works_count > 0 AND tags.canonical = 1')
  }

  scope :visible_to_registered_user_with_count, -> {
    joins(:filter_count).
    select("tags.*, filter_counts.unhidden_works_count as count").
    where('filter_counts.unhidden_works_count > 0 AND tags.canonical = 1')
  }

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

  scope :popular, -> {
    (User.current_user.is_a?(Admin) || User.current_user.is_a?(User)) ?
      visible_to_registered_user_with_count.order('filter_counts.unhidden_works_count DESC') :
      visible_to_all_with_count.order('filter_counts.public_works_count DESC')
  }

  scope :random, -> {
    (User.current_user.is_a?(Admin) || User.current_user.is_a?(User)) ?
    visible_to_registered_user_with_count.order("RAND()") :
    visible_to_all_with_count.order("RAND()")
  }

  scope :with_count, -> {
    (User.current_user.is_a?(Admin) || User.current_user.is_a?(User)) ?
      visible_to_registered_user_with_count : visible_to_all_with_count
  }

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

  # Get the tags for a challenge's signups, checking both the main tag set
  # and the optional tag set for each prompt
  def self.in_challenge(collection, prompt_type=nil)
    ['', 'optional_'].map { |tag_set_type|
      join = "INNER JOIN set_taggings ON (tags.id = set_taggings.tag_id)
        INNER JOIN tag_sets ON (set_taggings.tag_set_id = tag_sets.id)
        INNER JOIN prompts ON (prompts.#{tag_set_type}tag_set_id = tag_sets.id)
        INNER JOIN challenge_signups ON (prompts.challenge_signup_id = challenge_signups.id)"

      tags = self.joins(join).where("challenge_signups.collection_id = ?", collection.id)
      tags = tags.where("prompts.type = ?", prompt_type) if prompt_type.present?
      tags
    }.flatten.compact.uniq
  end

  scope :requested_in_challenge, lambda {|collection|
    in_challenge(collection, 'Request')
  }

  scope :offered_in_challenge, lambda {|collection|
    in_challenge(collection, 'Offer')
  }

  # Resque

  @queue = :utilities
  # This will be called by a worker when a job needs to be processed
  def self.perform(id, method, *args)
    # we are doing this to step over issues when the tag is deleted.
    # in rails 4 this should be tag=find_by id: id
    tag = find_by(id: id)
    tag.send(method, *args) unless tag.nil?
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

  def display_name
    name
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
        REDIS_AUTOCOMPLETE.zadd("autocomplete_fandom_#{parent.name.downcase}_#{type.downcase}", score, autocomplete_value) if parent.is_a?(Fandom)
      end
    end
    super
  end

  def remove_from_autocomplete
    super
    if self.is_a?(Character) || self.is_a?(Relationship)
      parents.each do |parent|
        REDIS_AUTOCOMPLETE.zrem("autocomplete_fandom_#{parent.name.downcase}_#{type.downcase}", autocomplete_value) if parent.is_a?(Fandom)
      end
    end
  end

  def remove_stale_from_autocomplete
    super
    if self.is_a?(Character) || self.is_a?(Relationship)
      parents.each do |parent|
        REDIS_AUTOCOMPLETE.zrem("autocomplete_fandom_#{parent.name.downcase}_#{type.downcase}", autocomplete_value_before_last_save) if parent.is_a?(Fandom)
      end
    end
  end

  def self.parse_autocomplete_value(current_autocomplete_value)
    current_autocomplete_value.split(AUTOCOMPLETE_DELIMITER, 2)
  end


  def autocomplete_score
    taggings_count_cache
  end

  # look up tags that have been wrangled into a given fandom
  def self.autocomplete_fandom_lookup(options = {})
    options.reverse_merge!({term: "", tag_type: "character", fandom: "", fallback: true})
    search_param = options[:term]
    tag_type = options[:tag_type]
    fandoms = Tag.get_search_terms(options[:fandom])

    # fandom sets are too small to bother breaking up
    # we're just getting ALL the tags in the set(s) for the fandom(s) and then manually matching
    results = []
    fandoms.each do |single_fandom|
      if search_param.blank?
        # just return ALL the characters
        results += REDIS_AUTOCOMPLETE.zrevrange("autocomplete_fandom_#{single_fandom}_#{tag_type}", 0, -1)
      else
        search_regex = Tag.get_search_regex(search_param)
        results += REDIS_AUTOCOMPLETE.zrevrange("autocomplete_fandom_#{single_fandom}_#{tag_type}", 0, -1).select {|tag| tag.match(search_regex)}
      end
    end
    if options[:fallback] && results.empty? && search_param.length > 0
      # do a standard tag lookup instead
      Tag.autocomplete_lookup(search_param: search_param, autocomplete_prefix: "autocomplete_tag_#{tag_type}")
    else
      results
    end
  end

  ## END AUTOCOMPLETE



  # Substitute characters that are particularly prone to cause trouble in urls
  def self.find_by_name(string)
    return unless string.is_a? String
    string = string.gsub(
      /\*[sadqh]\*/,
      '*s*' => '/',
      '*a*' => '&',
      '*d*' => '.',
      '*q*' => '?',
      '*h*' => '#'
    )
    self.where('tags.name = ?', string).first
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
        self.create(name: new_name, type: self.to_s)
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

  def unfilterable?
    !(self.canonical? || self.unwrangleable? || self.merger_id.present? || self.mergers.any?)
  end

  # Returns true if a tag has been used in posted works
  def has_posted_works?
    self.works.posted.any?
  end

  # sort tags by name
  def <=>(another_tag)
    name.downcase <=> another_tag.name.downcase
  end

  # only allow changing the tag type for unwrangled tags not used in any tag sets or on any works
  def can_change_type?
    self.unfilterable? && self.set_taggings.count == 0 && self.works.count == 0
  end

  # tags having their type changed need to be reloaded to be seen as an instance of the proper subclass
  def recategorize(new_type)
    self.update_attribute(:type, new_type)
    # return a new instance of the tag, with the correct class
    Tag.find(self.id)
  end

  #### FILTERING ####

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
    series_ids = all_filtered_series_ids
    external_work_ids = all_filtered_external_work_ids
    bookmark_ids = all_bookmark_ids
    yield if block_given?
    reindex_all_works(work_ids)
    reindex_all_series(series_ids)
    reindex_all_external_works(external_work_ids)
    reindex_all_bookmarks(bookmark_ids)
    reindex_pseuds if type == "Fandom"
  end

  # Take the most direct route from tag to pseud and queue up to reindex
  def reindex_pseuds
    Creatorship.select(:id, :pseud_id).
                joins("JOIN filter_taggings ON filter_taggings.filterable_id = creatorships.creation_id").
                where("filter_taggings.filter_id = ? AND filter_taggings.filterable_type = 'Work' AND creatorships.creation_type = 'Work'", id).
                find_in_batches do |batch|
      IndexQueue.enqueue_ids(Pseud, batch.map(&:pseud_id), :background)
    end
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
    (self.filter_taggings.where(filterable_type: "Work").pluck(:filterable_id) +
      self.works.pluck(:id)).uniq
  end

  # Reindex all series (series_ids argument works as above)
  def reindex_all_series(series_ids = [])
    if series_ids.empty?
      series_ids = all_filtered_series_ids
    end
    IndexQueue.enqueue_ids(Series, series_ids, :background)
  end

  # Series get their filters through works, so we go through SerialWork, which has
  # both work and series ids
  def all_filtered_series_ids
    SerialWork.where(work_id: all_filtered_work_ids).pluck(:series_id).uniq
  end

  # In the case of external works, the filter_taggings table already collects all the
  # things tagged by this tag or its subtags/synonyms
  def all_filtered_external_work_ids
    # all synned and subtagged external works should be under filter taggings
    # add in the direct external works for any noncanonical tags
    (filter_taggings.where(filterable_type: "ExternalWork").pluck(:filterable_id) +
      external_works.pluck(:id)).uniq
  end

  # Reindex all external works (external_work_ids argument works as above)
  def reindex_all_external_works(external_work_ids = [])
    if external_work_ids.empty?
      external_work_ids = all_filtered_external_work_ids
    end
    IndexQueue.enqueue_ids(ExternalWork, external_work_ids, :background)
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
    self.bookmarks.pluck(:id) +
      self.sub_tags.collect {|subtag| subtag.all_bookmark_ids(depth+1)}.flatten +
      self.mergers.collect {|syn| syn.all_bookmark_ids(depth+1)}.flatten
  end

  def filtered_items
    filtered_works + filtered_external_works
  end

  def reindex_filtered_item(item)
    if item.is_a?(Work)
      RedisSearchIndexQueue.reindex(item, priority: :low)
      IndexQueue.enqueue_ids(Series, item.series.pluck(:id), :background)
    else
      IndexQueue.enqueue_id("ExternalWork", item.id, :background)
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
    reset_filter_count
  end

  # If a tag has a new merger, add to the filter_taggings for that merger
  # If a tag has a new merger but had an old merger, add new filter_taggings
  # and get rid of the old filter_taggings as appropriate
  def update_filters_for_merger_change
    if self.merger_id_changed?
      # setting the merger_id doesn't update the merger so we do it here
      if self.merger_id
        self.merger = Tag.find_by(id: self.merger_id)
      else
        self.merger = nil
      end
      if self.merger && self.merger.canonical?
        self.async(:add_filter_taggings)
      end
      old_merger = Tag.find_by(id: self.merger_id_was)
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
    return unless filter_tag && !filter_tag.new_record?

    # we collect tags for resetting count so that it's only done once after we've added all filters to works
    tags_that_need_filter_count_reset = []
    items = self.works + self.external_works
    items.each do |item|
      if item.filters.include?(filter_tag)
        # If the item filters already included the filter tag (e.g. because the
        # new filter tag is a meta tag of an existing tag) we make sure to set
        # the inheritance to false, since the item is now directly tagged with
        # the filter or one of its synonyms
        ft = item.filter_taggings.where(["filter_id = ?", filter_tag.id]).first
        ft.update_attribute(:inherited, false)
      else
        FilterTagging.create(
          filter: filter_tag,
          filterable: item
        )
        # As of Rails 5 upgrade, this triggers a stack level too deep error
        # because it triggers the `before_update
        # :update_filters_for_canonical_change` callback. In 4.2 and before,
        # after this point `canonical_changed?` has been reset and returns
        # false. Now it returns true and causes an endless loop.
        #
        # Reference: https://github.com/rails/rails/issues/28908
        #
        # TODO: Keep an eye on this issue. We should not have to create the
        # FilterTagging directly.
        #
        # work.filters << filter_tag
        unless item.is_a?(ExternalWork) || tags_that_need_filter_count_reset.include?(filter_tag)
          tags_that_need_filter_count_reset << filter_tag
        end
      end
      unless filter_tag.meta_tags.empty?
        filter_tag.meta_tags.each do |m|
          next if item.filters.include?(m)
          item.filter_taggings.create!(inherited: true, filter_id: m.id)
          unless item.is_a?(ExternalWork) || tags_that_need_filter_count_reset.include?(m)
            tags_that_need_filter_count_reset << m
          end
        end
      end
    end

    # make sure that all the works and bookmarks under this tag get reindexed
    # for filtering/searching
    async(:reindex_taggables)

    FilterCount.enqueue_filters(tags_that_need_filter_count_reset)
  end

  # Remove filter taggings for a given tag
  # If an old_filter value is given, remove filter_taggings from it with due regard
  # for potential duplication (ie, items tagged with more than one synonymous tag)
  def remove_filter_taggings(old_filter_id = nil)
    # we're going to have to reindex all the taggables that WERE attached to this work after
    # we do this
    reindex_taggables do
      if old_filter_id
        old_filter = Tag.find(old_filter_id)
        # An old merger of a tag needs to be removed
        # This means we remove the old merger itself and all its meta tags unless they
        # should remain because of other existing tags of the item (or because they are
        # also meta tags of the new merger)
        filters_to_remove = [old_filter] + old_filter.meta_tags
        items = self.works + self.external_works
        items.each do |item|
          filters_to_remove.each do |filter_to_remove|
            next unless item.filters.include?(filter_to_remove)
            # We collect all sub tags, i.e. the tags that would have the filter_to_remove as
            # meta. If any of these or its mergers (synonyms) are tags of the item, the
            # filter_to_remove remains
            all_sub_tags = filter_to_remove.sub_tags + [filter_to_remove]
            sub_mergers = all_sub_tags.empty? ? [] : all_sub_tags.collect(&:mergers).flatten.compact
            all_tags_with_filter_to_remove_as_meta = all_sub_tags + sub_mergers
            # don't include self because at this point in time (before the save) self
            # is still in the list of submergers from when it was a synonym to the old filter
            remaining_tags = item.tags - [self]
            # instead we add the new merger of self (if there is one) as the relevant one to check
            remaining_tags += [self.merger] unless self.merger.nil?
            if (remaining_tags & all_tags_with_filter_to_remove_as_meta).empty? # none of the remaining tags need filter_to_remove
              item.filter_taggings.where(filter_id: filter_to_remove).destroy_all
            else # we should keep filter_to_remove, but check if inheritence needs to be updated
              direct_tags_for_filter_to_remove = filter_to_remove.mergers + [filter_to_remove]
              if (remaining_tags & direct_tags_for_filter_to_remove).empty? # not tagged with filter or mergers directly
                ft = item.filter_taggings.where(["filter_id = ?", filter_to_remove.id]).first
                ft.update_attribute(:inherited, true)
              end
            end
          end
        end

        FilterCount.enqueue_filters(filters_to_remove)
      else
        self.filter_taggings.destroy_all
        self.reset_filter_count
      end
    end
  end

  # Add filter taggings to this tag's items for one of its meta tags
  def inherit_meta_filters(meta_tag_id)
    meta_tag = Tag.find_by(id: meta_tag_id)
    return unless meta_tag.present?
    filtered_items.each do |item|
      unless item.filters.include?(meta_tag)
        item.filter_taggings.create!(inherited: true, filter_id: meta_tag.id)
        reindex_filtered_item(item)
      end
    end

    meta_tag.reset_filter_count
  end

  def reset_filter_count
    FilterCount.enqueue_filter(filter)
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
    self.external_works.where(hidden_by_admin: false).count
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
  def add_association(tag)
    build_association(tag).save
  end

  def has_parent?(tag)
    self.common_taggings.where(filterable_id: tag.id).count > 0
  end

  def has_child?(tag)
    self.child_taggings.where(common_tag_id: tag.id).count > 0
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
        tag.update_attributes(merger_id: nil)
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
    sub_tags.each { |sub| sub.meta_tags.delete(meta_tag) if sub.meta_tags.include?(meta_tag) }
    # remove inherited meta tags from this tag and all of its sub tags
    inherited_meta_tags = meta_tag.meta_tags
    inherited_meta_tags.each do |tag|
      self.meta_tags.delete(tag) if self.meta_tags.include?(tag)
      sub_tags.each { |sub| sub.meta_tags.delete(tag) if sub.meta_tags.include?(tag) }
    end
    # remove filters for meta tag from this tag's works and external works
    other_sub_tags = meta_tag.sub_tags - ([self] + self.sub_tags)
    filtered_items.each do |item|
      to_remove = [meta_tag] + inherited_meta_tags
      to_remove.each do |tag|
        next unless item.filters.include?(tag) && (item.filters & other_sub_tags).empty?
        unless item.tags.include?(tag) || !(item.tags & tag.mergers).empty?
          item.filter_taggings.where(filter_id: tag.id).destroy_all
          reindex_filtered_item(item)
        end
      end
    end
    meta_tag.update_works_index_timestamp!
    FilterCount.enqueue_filters([meta_tag] + inherited_meta_tags)
  end

  def remove_sub_filters(sub_tag)
    sub_tag.update_meta_filters(self)
  end

  # If we're making a tag non-canonical, we need to update its synonyms and children and favorite tags
  before_update :check_canonical
  def check_canonical
    if self.canonical_changed? && !self.canonical?
      self.async(:remove_canonical_associations)
      async(:remove_favorite_tags)
    elsif self.canonical_changed? && self.canonical?
      self.merger_id = nil
    end
    true
  end

  def remove_canonical_associations
    self.mergers.each {|tag| tag.update_attributes(merger_id: nil) if tag.merger_id == self.id }
    self.children.each {|tag| tag.parents.delete(self) if tag.parents.include?(self) }
    self.sub_tags.each {|tag| tag.meta_tags.delete(self) if tag.meta_tags.include?(self) }
    self.meta_tags.each {|tag| self.meta_tags.delete(tag) if self.meta_tags.include?(tag) }
  end

  def remove_favorite_tags
    favorite_tags.destroy_all
  end

  attr_reader :meta_tag_string, :sub_tag_string, :merger_string

  # Uses the value of parent_types to determine whether the passed-in tag
  # should be added as a parent or a child, and then generates the association
  # (if it doesn't already exist). If it does already exist, returns the
  # existing CommonTagging object.
  def build_association(tag)
    if parent_types.include?(tag&.type)
      common_taggings.find_or_initialize_by(filterable: tag)
    else
      child_taggings.find_or_initialize_by(common_tag: tag)
    end
  end

  # Splits up the passed-in string into a sequence of individual tag names,
  # then finds (and yields) the tag for each. Used by add_association_string,
  # meta_tag_string=, and sub_tag_string=.
  def parse_tag_string(tag_string)
    tag_string.split(",").map(&:squish).each do |name|
      yield name, Tag.find_by_name(name)
    end
  end

  # Try to create new associations with the tags of type tag_type whose names
  # are listed in tag_string.
  def add_association_string(tag_type, tag_string)
    parse_tag_string(tag_string) do |name, parent|
      prefix = "Cannot add association to '#{name}':"
      if parent && parent.type != tag_type
        errors.add(:base, "#{prefix} #{parent.type} added in #{tag_type} field.")
      else
        association = build_association(parent)
        save_and_gather_errors(association, prefix)
      end
    end
  end

  # Save an item to the database, if it's valid. If it's invalid, read in the
  # error messages from the item and copy them over to this tag.
  def save_and_gather_errors(item, prefix)
    return unless item.new_record? || item.changed?
    return if item.valid? && item.save

    item.errors.full_messages.each do |message|
      errors.add(:base, "#{prefix} #{message}")
    end
  end

  # Find and destroy all invalid CommonTaggings and MetaTaggings associated
  # with this tag.
  def destroy_invalid_associations
    common_taggings.destroy_invalid
    child_taggings.destroy_invalid
    meta_taggings.destroy_invalid
    sub_taggings.destroy_invalid
  end

  # defines fandom_string=, media_string=, character_string=, relationship_string=, freeform_string= 
  %w(Fandom Media Character Relationship Freeform).each do |tag_type|
    attr_reader "#{tag_type.downcase}_string"

    define_method("#{tag_type.downcase}_string=") do |tag_string|
      add_association_string(tag_type, tag_string)
    end
  end

  def meta_tag_string=(tag_string)
    parse_tag_string(tag_string) do |name, parent|
      meta_tagging = meta_taggings.build(meta_tag: parent, direct: true)
      save_and_gather_errors(meta_tagging, "Invalid meta tag '#{name}':")
    end
  end

  def sub_tag_string=(tag_string)
    parse_tag_string(tag_string) do |name, sub|
      sub_tagging = sub_taggings.build(sub_tag: sub, direct: true)
      save_and_gather_errors(sub_tagging, "Invalid sub tag '#{name}':")
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
          new_merger = self.class.new(name: tag_string, canonical: true)
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
      self.mergers.each {|m| m.update_attributes(merger_id: new_merger.id)}
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
        syn.update_attributes(merger_id: self.id)
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
    cond = rec ? {rec: true, private: false, hidden_by_admin: false} : {private: false, hidden_by_admin: false}
    work_bookmarks = Bookmark.where(bookmarkable_id: self.work_ids, bookmarkable_type: 'Work').merge(cond)
    ext_work_bookmarks = Bookmark.where(bookmarkable_id: self.external_work_ids, bookmarkable_type: 'ExternalWork').merge(cond)
    series_bookmarks = [] # can't tag a series directly? # Bookmark.where(bookmarkable_id: self.series_ids, bookmarkable_type: 'Series').merge(cond)
    (work_bookmarks + ext_work_bookmarks + series_bookmarks)
  end

  #################################
  ## SEARCH #######################
  #################################

  def unwrangled_query(tag_type, options = {})
    self_type = %w(Character Fandom Media).include?(self.type) ? self.type.downcase : "fandom"
    TagQuery.new(options.merge(
      type: tag_type,
      unwrangleable: false,
      wrangled: false,
      "pre_#{self_type}_ids": [self.id],
      per_page: Tag.per_page
    ))
  end

  def unwrangled_tags(tag_type, options = {})
    unwrangled_query(tag_type, options).search_results
  end

  def unwrangled_tag_count(tag_type)
    key = "unwrangled_#{tag_type}_#{self.id}_#{self.updated_at}"
    Rails.cache.fetch(key, expires_in: 4.hours) do
      unwrangled_query(tag_type).count
    end
  end

  def suggested_parent_tags(parent_type, options = {})
    limit = options[:limit] || 50
    work_ids = works.limit(limit).pluck(:id)
    Tag.distinct.joins(:taggings).where(
      "tags.type" => parent_type,
      taggings: {
        taggable_type: 'Work',
        taggable_id: work_ids
      }
    )
  end

  # For works that haven't been wrangled yet, get the fandom/character tags
  # that are used on their works as a place to start
  def suggested_parent_ids(parent_type)
    return [] if !parent_types.include?(parent_type) ||
      unwrangleable? ||
      parents.by_type(parent_type).exists?

    suggested_parent_tags(parent_type).pluck(:id, :merger_id).
                                       flatten.compact.uniq
  end

  def queue_child_tags_for_reindex
    all_with_child_type = Tag.where(type: child_types & Tag::USER_DEFINED)
    works.select(:id).find_in_batches do |batch|
      relevant_taggings = Tagging.where(taggable: batch)
      tag_ids = all_with_child_type.joins(:taggings).merge(relevant_taggings).distinct.pluck(:id)
      IndexQueue.enqueue_ids(Tag, tag_ids, :background)
    end
  end

  after_create :after_create
  def after_create
    tag = self
    if tag.canonical
      tag.add_to_autocomplete
    end
    update_tag_nominations(tag)
  end

  after_update :after_update
  def after_update
    tag = self
    if tag.saved_change_to_canonical?
      if tag.canonical
        # newly canonical tag
        tag.add_to_autocomplete
      else
        # decanonicalised tag
        tag.remove_from_autocomplete
      end
    elsif tag.canonical
      # clean up the autocomplete
      tag.remove_stale_from_autocomplete
      tag.add_to_autocomplete
    end

    # Expire caching when a merger is added or removed
    if tag.saved_change_to_merger_id?
      if tag.merger_id_before_last_save.present?
        old = Tag.find(tag.merger_id_before_last_save)
        old.update_works_index_timestamp!
      end
      if tag.merger_id.present?
        tag.merger.update_works_index_timestamp!
      end
      async(:queue_child_tags_for_reindex)
    end

    # if type has changed, expire the tag's parents' children cache (it stores the children's type)
    if tag.saved_change_to_type?
      tag.parents.each do |parent_tag|
        ActionController::Base.new.expire_fragment("views/tags/#{parent_tag.id}/children")
      end
    end

    # Reindex immediately to update the unwrangled bin.
    if tag.saved_change_to_unwrangleable?
      tag.reindex_document
    end

    update_tag_nominations(tag)
  end

  before_destroy :before_destroy
  def before_destroy
    tag = self
    if Tag::USER_DEFINED.include?(tag.type) && tag.canonical
      tag.remove_from_autocomplete
    end
    update_tag_nominations(tag, true)
  end

  private

  def update_tag_nominations(tag, deleted=false)
    values = {}
    if deleted
      values[:canonical] = false
      values[:exists] = false
      values[:parented] = false
      values[:synonym] = nil
    else
      values[:canonical] = tag.canonical
      values[:synonym] = tag.merger.nil? ? nil : tag.merger.name
      values[:parented] = tag.parents.any? {|p| p.is_a?(Fandom)}
      values[:exists] = true
    end
    TagNomination.where(tagname: tag.name).update_all(values)
  end

end
