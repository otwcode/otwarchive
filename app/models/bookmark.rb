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
  scope :recent, limit(ArchiveConfig.SEARCH_RESULTS_MAX)
  scope :recs, where(:rec => true)
  scope :latest, is_public.limit(ArchiveConfig.ITEMS_PER_PAGE)

  scope :in_collection, lambda {|collection|
    select("DISTINCT bookmarks.*").
    joins(:collection_items).
    where('collection_items.collection_id IN (?) AND collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?',
            [collection.id] + collection.children.collect(&:id), CollectionItem::APPROVED, CollectionItem::APPROVED)
  }

  scope :join_work,
    joins("LEFT JOIN works ON (bookmarks.bookmarkable_id = works.id AND bookmarks.bookmarkable_type = 'Work')") &
    Work.visible_to_all

  scope :join_series,
    joins("LEFT JOIN series ON (bookmarks.bookmarkable_id = series.id AND bookmarks.bookmarkable_type = 'Series')") &
    Series.visible_to_all

  scope :join_external_works,
    joins("LEFT JOIN external_works ON (bookmarks.bookmarkable_id = external_works.id AND bookmarks.bookmarkable_type = 'ExternalWork')") &
    ExternalWork.visible_to_all

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

  # a complicated dynamic scope here:
  # if the user is an Admin, we use the "visible_to_admin" scope
  # if the user is not a logged-in User, we use the "visible_to_all" scope
  # otherwise, we use a join to get userids and then get all posted works that are either unhidden OR belong to this user.
  # Note: in that last case we have to use select("DISTINCT works.") because of cases where the same user appears twice
  # on a work.
  scope :visible_to_user, lambda {|user|
   user.is_a?(Admin) ? visible_to_admin :
     (!user.is_a?(User) ? visible_to_all :
      select("DISTINCT bookmarks.*").visible_to_registered_user.joins({:pseud => :user}).where("bookmarks.hidden_by_admin = 0 OR users.id = ?", user.id))
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
  
  self.include_root_in_json = false
  def to_indexed_json
    to_json(methods: [:pseud_name, :work_pseud_names, :work_pseud_ids, :tag_names, :tag_ids, :filter_names, :fandom_ids, :character_ids, :relationship_ids, :freeform_ids, :rating_ids, :warning_ids, :category_ids, :work_title, :work_posted, :work_restricted, :work_complete, :work_language_id, :collection_ids, :work_collection_ids])
  end
  
  def self.search(options={})
    if options[:other_tag_names].present?
      names = options[:other_tag_names].split(",")
      tags = Tag.where(:name => names)
      tags.each do |tag|
        facet_key = "#{tag.type.to_s.downcase}_ids".to_sym
        options[facet_key] ||= []
        options[facet_key] << tag.id
      end
    end
    tire.search(page: options[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE, load: true) do
      query do
        boolean do
          must { string options[:query], default_operator: "AND" } if options[:query].present?
          [:work_pseud_ids, :tag_ids, :fandom_ids, :character_ids, :relationship_ids, :freeform_ids, :rating_ids, :warning_ids, :category_ids, :collection_ids, :work_collection_ids].each do |id_list|
            if options[id_list].present?
              options[id_list].each do |id|
                must { term id_list, id }
              end
            end
          end
          must { terms :pseud_id, options[:pseud_ids] } if options[:pseud_ids].present?
          must { term :private, 'F' } unless options[:private]
        end
      end
      sort { by :created_at, "desc" } if options[:query].blank?
      facet "rating" do
        terms :rating_ids
      end
      facet "warning" do
        terms :warning_ids
      end
      facet "category" do
        terms :category_ids
      end
      facet "fandom" do
        terms :fandom_ids
      end
      facet "character" do
        terms :character_ids
      end
      facet "relationship" do
        terms :relationship_ids
      end
      facet "freeform" do
        terms :freeform_ids
      end
    end
  end
  
  
  def pseud_name
    pseud.name
  end
  
  def work_pseud_names
    if bookmarkable.respond_to?(:pseuds)
      bookmarkable.pseuds.value_of(:name)
    elsif bookmarkable.respond_to?(:author)
      bookmarkable.author
    end
  end
  
  def work_pseud_ids
    if bookmarkable.respond_to?(:creatorships)
      bookmarkable.creatorships.value_of(:pseud_id)
    end
  end
  
  def tag_names
    self.tags.value_of(:name)
  end
  
  def tag_ids
    self.tags.value_of(:id)
  end
  
  def filters
    if @filters.nil?
      @filters = self.tags.map{ |t| t.filter }.compact
      if bookmarkable.respond_to?(:filters)
        @filters = (@filters + bookmarkable.filters).uniq
      end
    end
    @filters
  end
  
  def filter_names
    filters.map{ |t| t.name }
  end
  
  def fandom_ids
    filters.map{ |t| t.id if t.type.to_s == 'Fandom' }.compact
  end
  
  def character_ids
    filters.map{ |t| t.id if t.type.to_s == 'Character' }.compact
  end
  
  def relationship_ids
    filters.map{ |t| t.id if t.type.to_s == 'Relationship' }.compact
  end
  
  def freeform_ids
    filters.map{ |t| t.id if t.type.to_s == 'Freeform' }.compact
  end
  
  def rating_ids
    filters.map{ |t| t.id if t.type.to_s == 'Rating' }.compact
  end
  
  def warning_ids
    filters.map{ |t| t.id if t.type.to_s == 'Warning' }.compact
  end
  
  def category_ids
    filters.map{ |t| t.id if t.type.to_s == 'Category' }.compact
  end
  
  def collection_ids
    collections.value_of :id
  end
  
  def work_collection_ids
    bookmarkable.collections.value_of(:id) if bookmarkable.respond_to?(:collections)
  end
  
  def work_title
    bookmarkable.try(:title)
  end
  
  def work_posted
    !bookmarkable.respond_to?(:posted) || bookmarkable.posted?
  end
  
  def work_restricted
    bookmarkable.respond_to?(:restricted) && bookmarkable.restricted?
  end
  
  def work_complete
    !bookmarkable.respond_to?(:complete) || bookmarkable.complete?
  end
  
  def work_language_id
    bookmarkable.language_id if bookmarkable.respond_to?(:language_id)
  end

end
