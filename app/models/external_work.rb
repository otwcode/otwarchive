include UrlHelpers
class ExternalWork < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  include Bookmarkable
  include Searchable

  has_many :related_works, as: :parent

  belongs_to :language

  scope :duplicate, -> { group("url HAVING count(DISTINCT id) > 1") }

  AUTHOR_LENGTH_MAX = 500

  validates_presence_of :title
  validates_length_of :title, minimum: ArchiveConfig.TITLE_MIN,
                              too_short: ts("must be at least %{min} characters long.",
                                            min: ArchiveConfig.TITLE_MIN)
  validates_length_of :title, maximum: ArchiveConfig.TITLE_MAX,
                              too_long: ts("must be less than %{max} characters long.",
                                           max: ArchiveConfig.TITLE_MAX)

  validates_length_of :summary, allow_blank: true, maximum: ArchiveConfig.SUMMARY_MAX,
                                too_long: ts("must be less than %{max} characters long.",
                                             max: ArchiveConfig.SUMMARY_MAX)

  validates_presence_of :author, message: ts('^Creator can\'t be blank')
  validates_length_of :author, maximum: AUTHOR_LENGTH_MAX,
                               too_long: ts('^Creator must be less than %{max} characters long.',
                                            max: AUTHOR_LENGTH_MAX)

  # TODO: External works should have fandoms, but they currently don't get added through the
  # post new work form so we can't validate them
  #validates_presence_of :fandoms

  before_validation :cleanup_url
  validates :url, presence: true, url_format: true, url_active: true
  def cleanup_url
    self.url = reformat_url(self.url) if self.url
  end

  # Sets the dead? attribute to true if the link is no longer active
  def set_url_status
    self.update_attribute(:dead, true) unless url_active?(self.url)
  end

  ########################################################################
  # VISIBILITY
  ########################################################################
  # Adapted from work.rb

  scope :visible_to_all, -> { where(hidden_by_admin: false) }
  scope :visible_to_registered_user, -> { where(hidden_by_admin: false) }
  scope :visible_to_admin, -> { where("") }

  # a complicated dynamic scope here:
  # if the user is an Admin, we use the "visible_to_admin" scope
  # if the user is not a logged-in User, we use the "visible_to_all" scope
  # otherwise, we use a join to get userids and then get all posted works that are either unhidden OR belong to this user.
  # Note: in that last case we have to use select("DISTINCT works.") because of cases where the same user appears twice
  # on a work.
  scope :visible_to_user, lambda {|user| user.is_a?(Admin) ? visible_to_admin : visible_to_all}

  # Use the current user to determine what external works are visible
  scope :visible, -> { visible_to_user(User.current_user) }

  # Visible unless we're hidden by admin, in which case only an Admin can see.
  def visible?(user=User.current_user)
    self.hidden_by_admin? ? user.kind_of?(Admin) : true
  end

  alias_method :visible, :visible?

  # Visibility has changed, which means we need to reindex
  # the external work's bookmarker pseuds, to update their bookmark counts.
  def should_reindex_pseuds?
    pertinent_attributes = %w[id hidden_by_admin]
    destroyed? || (saved_changes.keys & pertinent_attributes).present?
  end

  #######################################################################
  # TAGGING
  # External works are taggable objects.
  #######################################################################

  # FILTERING CALLBACKS
  after_save :check_filter_taggings

  # Add and remove filter taggings as tags are added and removed
  def check_filter_taggings
    # Add filter taggings for tags on the work
    current_filters = self.tags.map { |tag| tag.canonical? ? tag : tag.merger }.compact
    current_filters.each { |filter| self.add_filter_tagging(filter) }

    # Add filter taggings for the tags' meta tags
    current_meta_filters = current_filters.map(&:meta_tags).flatten.compact
    current_meta_filters.each { |filter| self.add_filter_tagging(filter, true) }

    # Remove any filter taggings that do not come from the tags or their meta tags
    filters_to_remove = self.filters - (current_filters + current_meta_filters)
    unless filters_to_remove.empty?
      filters_to_remove.each { |filter| self.remove_filter_tagging(filter) }
    end
    return true
  end

  # Creates a filter_tagging relationship between the work and the tag or its canonical synonym
  def add_filter_tagging(tag, meta = false)
    filter = tag.canonical? ? tag : tag.merger
    if filter
      if !self.filters.include?(filter)
        if meta
          self.filter_taggings.create(filter_id: filter.id, inherited: true)
        else
          self.filters << filter
        end
      elsif !meta
        ft = self.filter_taggings.where(["filter_id = ?", filter.id]).first
        ft.update_attribute(:inherited, false)
      end
    end
  end

  # Removes filter_tagging relationship unless the work is tagged with more than one synonymous tags
  def remove_filter_tagging(tag)
    filter = tag.canonical? ? tag : tag.merger
    if filter && (self.tags & tag.synonyms).empty? && self.filters.include?(filter)
      self.filters.delete(filter)
      filter.reset_filter_count
    end
  end

  def tag_groups
    self.tags.group_by { |t| t.type.to_s }
  end

  ######################
  # SEARCH
  ######################

  def bookmarkable_json
    as_json(
      root: false,
      only: [
        :title, :summary, :hidden_by_admin, :created_at, :language_id
      ],
      methods: [
        :posted, :restricted, :tag, :filter_ids, :rating_ids,
        :archive_warning_ids, :category_ids, :fandom_ids, :character_ids,
        :relationship_ids, :freeform_ids, :creators, :revised_at
      ]
    ).merge(
      bookmarkable_type: "ExternalWork",
      bookmarkable_join: { name: "bookmarkable" }
    )
  end

  def posted
    true
  end
  alias_method :posted?, :posted

  def restricted
    false
  end
  alias_method :restricted?, :restricted

  def creators
    [author]
  end

  def revised_at
    created_at
  end
  include Taggable

end
