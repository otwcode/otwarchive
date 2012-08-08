class Bookmark < ActiveRecord::Base

  include Collectible

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

  # Index for Thinking Sphinx
  define_index do

    # fields
    indexes bookmarkable_type, :as => 'type'
    indexes notes

    # associations
    indexes pseud(:name), :as => 'bookmarker'
    indexes tags(:name), :as => 'tag'
# TODO polymorphic associations can’t currently be used in field or attribute definitions. This will be fixed at some point.
#    indexes bookmarkable.tags(:name), :as => 'indirect'

    # attributes
    has rec, updated_at, bookmarkable_id

    # Don't index private and hidden bookmarks
    where "private = 0 AND hidden_by_admin = 0"

    # properties
#    set_property :delta => :delayed
  end


end
