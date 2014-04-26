class Bookmark < ActiveRecord::Base

  include Collectible
  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :bookmarkable, :polymorphic => true
  belongs_to :pseud
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'

  attr_protected :notes_sanitizer_version

  validates_length_of :notes,
    :maximum => ArchiveConfig.NOTES_MAX, :too_long => ts("must be less than %{max} letters long.", :max => ArchiveConfig.NOTES_MAX)

  default_scope :order => "bookmarks.id DESC" # id's stand in for creation date

  # renaming scope :public -> :is_public because otherwise it overlaps with the "public" keyword
  scope :is_public, where(:private => false, :hidden_by_admin => false)
  scope :not_public, where(:private => true)
  scope :not_private, where(:private => false)
  scope :since, lambda { |*args| where("bookmarks.created_at > ?", (args.first || 1.week.ago)) }
  scope :recs, where(:rec => true)

  scope :in_collection, lambda {|collection|
    select("DISTINCT bookmarks.*").
    joins(:collection_items).
    where('collection_items.collection_id IN (?) AND collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?',
            [collection.id] + collection.children.collect(&:id), CollectionItem::APPROVED, CollectionItem::APPROVED)
  }

  scope :join_work,
    joins("LEFT JOIN works ON (bookmarks.bookmarkable_id = works.id AND bookmarks.bookmarkable_type = 'Work')").
    merge(Work.visible_to_all)

  scope :join_series,
    joins("LEFT JOIN series ON (bookmarks.bookmarkable_id = series.id AND bookmarks.bookmarkable_type = 'Series')").
    merge(Series.visible_to_all)

  scope :join_external_works,
    joins("LEFT JOIN external_works ON (bookmarks.bookmarkable_id = external_works.id AND bookmarks.bookmarkable_type = 'ExternalWork')").
    merge(ExternalWork.visible_to_all)

  scope :join_bookmarkable,
    joins("LEFT JOIN works ON (bookmarks.bookmarkable_id = works.id AND bookmarks.bookmarkable_type = 'Work')
           LEFT JOIN series ON (bookmarks.bookmarkable_id = series.id AND bookmarks.bookmarkable_type = 'Series')
           LEFT JOIN external_works ON (bookmarks.bookmarkable_id = external_works.id AND bookmarks.bookmarkable_type = 'ExternalWork')")

  scope :visible_to_all,
    is_public.join_bookmarkable.
    where("(works.posted = 1 AND works.restricted = 0 AND works.hidden_by_admin = 0) OR
      (series.restricted = 0 AND series.hidden_by_admin = 0) OR
      (external_works.hidden_by_admin = 0)")

  scope :visible_to_registered_user,
    is_public.join_bookmarkable.
    where("(works.posted = 1 AND works.hidden_by_admin = 0) OR
      (series.hidden_by_admin = 0) OR
      (external_works.hidden_by_admin = 0)")

  scope :visible_to_admin, not_private

  scope :latest, is_public.limit(ArchiveConfig.ITEMS_PER_PAGE).join_work

  # a complicated dynamic scope here:
  # if the user is an Admin, we use the "visible_to_admin" scope
  # if the user is not a logged-in User, we use the "visible_to_all" scope
  # otherwise, we use a join to get userids and then get all posted works that are either unhidden OR belong to this user.
  # Note: in that last case we have to use select("DISTINCT works.") because of cases where the same user appears twice
  # on a work.
  scope :visible_to_user, lambda {|user|
    if user.is_a?(Admin)
      visible_to_admin
    elsif !user.is_a?(User)
      visible_to_all
    else
      select("DISTINCT bookmarks.*").
      visible_to_registered_user.
      joins("JOIN pseuds as p1 ON p1.id = bookmarks.pseud_id JOIN users ON users.id = p1.user_id").
      where("bookmarks.hidden_by_admin = 0 OR users.id = ?", user.id)
    end
  }

  # Use the current user to determine what works are visible
  scope :visible, visible_to_user(User.current_user)

  def visible?(current_user=User.current_user)
    return true if current_user == self.pseud.user
    unless current_user == :false || !current_user
      # Admins should not see private bookmarks
      return true if current_user.is_a?(Admin) && self.private == false
    end
    if !(self.private? || self.hidden_by_admin?)
      if self.bookmarkable.nil?
        # only show bookmarks for deleted works to the user who
        # created the bookmark
        return true if pseud.user == current_user
      else
        if self.bookmarkable_type == 'Work' || self.bookmarkable_type == 'Series' || self.bookmarkable_type == 'ExternalWork'
          return true if self.bookmarkable.visible(current_user)
        else
          return true
        end
      end
    end
    return false
  end

  # Returns the number of bookmarks on an item visible to the current user
  def self.count_visible_bookmarks(bookmarkable, current_user=:false)
    bookmarkable.bookmarks.visible.count
  end

  # Virtual attribute for external works
  def external=(attributes)
    unless attributes.values.to_s.blank?
      !self.bookmarkable ? self.bookmarkable = ExternalWork.new(attributes) : self.bookmarkable.attributes = attributes
    end
  end

  def tag_string
    tags.map{|tag| tag.name}.join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
  end

  def tag_string=(tag_string)
    self.tags = []
    tag_string.split(ArchiveConfig.DELIMITER_FOR_INPUT).each do |string|
      string.squish!
      if !string.blank?
        tag = Tag.find_by_name(string)
        if tag
          self.tags << tag
        else
          self.tags << UnsortedTag.create(:name => string)
        end
      end
    end
    return self.tags
  end
  
  def self.list_without_filters(owner, options)
    bookmarks = owner.bookmarks
    user = nil
    if %w(Pseud User).include?(owner.class.to_s)
      user = owner.respond_to?(:user) ? owner.user : owner
    end
    unless User.current_user == user
      bookmarks = bookmarks.is_public
    end
    bookmarks = bookmarks.paginate(:page => options[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
  end
  
  #################################
  ## SEARCH #######################
  #################################

  mapping do
    indexes :notes
    indexes :private, :type => 'boolean'
    indexes :bookmarkable_type
    indexes :bookmarkable_id
    indexes :created_at,          :type  => 'date'
    indexes :bookmarkable_date,   :type  => 'date'
  end

  self.include_root_in_json = false
  def to_indexed_json
    to_json(methods: 
      [ :bookmarker, 
        :with_notes,
        :bookmarkable_pseud_names, 
        :bookmarkable_pseud_ids, 
        :tag, 
        :tag_ids, 
        :filter_names, 
        :filter_ids,
        :fandom_ids, 
        :character_ids, 
        :relationship_ids, 
        :freeform_ids, 
        :rating_ids, 
        :warning_ids, 
        :category_ids, 
        :bookmarkable_title, 
        :bookmarkable_posted, 
        :bookmarkable_restricted, 
        :bookmarkable_hidden,
        :bookmarkable_complete, 
        :bookmarkable_language_id, 
        :collection_ids, 
        :bookmarkable_collection_ids,
        :bookmarkable_date
      ])
  end 
  
  def bookmarker
    pseud.try(:name)
  end

  def with_notes
    notes.present?
  end
  
  def bookmarkable_pseud_names
    if bookmarkable.respond_to?(:creator)
      bookmarkable.creator
    elsif bookmarkable.respond_to?(:pseuds)
      bookmarkable.pseuds.value_of(:name)
    elsif bookmarkable.respond_to?(:author)
      bookmarkable.author
    end
  end
  
  def bookmarkable_pseud_ids
    if bookmarkable.respond_to?(:creatorships)
      bookmarkable.creatorships.value_of(:pseud_id)
    end
  end
  
  def tag
    names = self.tags.value_of(:name) + filter_names
    if bookmarkable.respond_to?(:tags)
      names += bookmarkable.tags.where(canonical: false).value_of :name
    end
    if bookmarkable.respond_to?(:work_tags)
      names += bookmarkable.work_tags.where(canonical: false).value_of :name
    end
    names.uniq
  end
  
  def tag_ids
    self.tags.value_of(:id)
  end
  
  def filters
    if @filters.nil?
      @filters = filters_for_facets
      if bookmarkable.respond_to?(:filters)
        @filters = (@filters + bookmarkable.filters.where("filter_taggings.inherited = 1")).uniq
      end
    end
    @filters
  end

  def filters_for_facets
    if @facet_filters.nil?
      @facet_filters = self.tags.map{ |t| t.filter }.compact
      if bookmarkable.respond_to?(:filters)
        @facet_filters = (@facet_filters + bookmarkable.filters.where("filter_taggings.inherited = 0")).uniq
      end
    end
    @facet_filters
  end
  
  def filter_names
    filters.map{ |t| t.name }
  end

  def filter_ids
    filters.map{ |t| t.id }
  end
  
  def fandom_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Fandom' }.map{ |t| t.id }
  end
  
  def character_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Character' }.map{ |t| t.id }
  end
  
  def relationship_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Relationship' }.map{ |t| t.id }
  end
  
  def freeform_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Freeform' }.map{ |t| t.id }
  end
  
  def rating_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Rating' }.map{ |t| t.id }
  end
  
  def warning_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Warning' }.map{ |t| t.id }
  end
  
  def category_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Category' }.map{ |t| t.id }
  end
  
  def collection_ids
    approved_collections.value_of(:id, :parent_id).flatten.uniq.compact
  end
  
  def bookmarkable_collection_ids
    if bookmarkable.respond_to?(:approved_collections)
      bookmarkable.approved_collections.value_of(:id, :parent_id).flatten.uniq.compact
    end
  end
  
  def bookmarkable_title
    bookmarkable.try(:title)
  end
  
  def bookmarkable_posted
    !bookmarkable.respond_to?(:posted) || bookmarkable.posted?
  end
  
  def bookmarkable_restricted
    bookmarkable.respond_to?(:restricted) && bookmarkable.restricted?
  end

  def bookmarkable_hidden
    bookmarkable.respond_to?(:hidden_by_admin) && bookmarkable.hidden_by_admin?
  end
  
  def bookmarkable_complete
    !bookmarkable.respond_to?(:complete) || bookmarkable.complete?
  end
  
  def bookmarkable_language_id
    bookmarkable.language_id if bookmarkable.respond_to?(:language_id)
  end

  def bookmarkable_date
    if bookmarkable.respond_to?(:revised_at)
      bookmarkable.revised_at
    elsif bookmarkable.respond_to?(:updated_at)
      bookmarkable.updated_at
    end
  end 

end
