class Collection < ApplicationRecord
  include Filterable
  include WorksOwner

  has_one_attached :icon do |attachable|
    attachable.variant(:standard, resize_to_limit: [100, 100])
  end

  # i18n-tasks-use t("errors.attributes.icon.invalid_format")
  # i18n-tasks-use t("errors.attributes.icon.too_large")
  validates :icon, attachment: {
    allowed_formats: %r{image/\S+},
    maximum_size: ArchiveConfig.ICON_SIZE_KB_MAX.kilobytes
  }

  belongs_to :parent, class_name: "Collection", inverse_of: :children
  has_many :children, class_name: "Collection", foreign_key: "parent_id", inverse_of: :parent

  has_one :collection_profile, dependent: :destroy
  accepts_nested_attributes_for :collection_profile

  has_one :collection_preference, dependent: :destroy
  accepts_nested_attributes_for :collection_preference

  before_validation :clear_icon
  before_validation :cleanup_url
  before_create :ensure_associated
  def ensure_associated
    self.collection_preference = CollectionPreference.new unless self.collection_preference
    self.collection_profile = CollectionProfile.new unless self.collection_profile
  end

  belongs_to :challenge, dependent: :destroy, polymorphic: true
  has_many :prompts, dependent: :destroy

  has_many :signups, class_name: "ChallengeSignup", dependent: :destroy
  has_many :potential_matches, dependent: :destroy
  has_many :assignments, class_name: "ChallengeAssignment", dependent: :destroy
  has_many :claims, class_name: "ChallengeClaim", dependent: :destroy

  # We need to get rid of all of these if the challenge is destroyed
  after_save :clean_up_challenge
  def clean_up_challenge
    return if self.challenge_id

    assignments.each(&:destroy)
    potential_matches.each(&:destroy)
    signups.each(&:destroy)
    prompts.each(&:destroy)
  end

  has_many :collection_items, dependent: :destroy
  accepts_nested_attributes_for :collection_items, allow_destroy: true
  has_many :approved_collection_items, -> { approved_by_both }, class_name: "CollectionItem"

  has_many :works, through: :collection_items, source: :item, source_type: "Work"
  has_many :approved_works, -> { posted }, through: :approved_collection_items, source: :item, source_type: "Work"

  has_many :bookmarks, through: :collection_items, source: :item, source_type: "Bookmark"
  has_many :approved_bookmarks, through: :approved_collection_items, source: :item, source_type: "Bookmark"

  has_many :collection_participants, dependent: :destroy
  accepts_nested_attributes_for :collection_participants, allow_destroy: true

  has_many :participants, through: :collection_participants, source: :pseud
  has_many :users, through: :participants, source: :user
  has_many :invited, -> { where(collection_participants: { participant_role: CollectionParticipant::INVITED }) }, through: :collection_participants, source: :pseud
  has_many :owners, -> { where(collection_participants: { participant_role: CollectionParticipant::OWNER }) }, through: :collection_participants, source: :pseud
  has_many :moderators, -> { where(collection_participants: { participant_role: CollectionParticipant::MODERATOR }) }, through: :collection_participants, source: :pseud
  has_many :members, -> { where(collection_participants: { participant_role: CollectionParticipant::MEMBER }) }, through: :collection_participants, source: :pseud
  has_many :posting_participants, -> { where(collection_participants: { participant_role: [CollectionParticipant::MEMBER, CollectionParticipant::MODERATOR, CollectionParticipant::OWNER] }) }, through: :collection_participants, source: :pseud

  CHALLENGE_TYPE_OPTIONS = [
    ["", ""],
    [ts("Gift Exchange"), "GiftExchange"],
    [ts("Prompt Meme"), "PromptMeme"]
  ].freeze

  validate :must_have_owners
  def must_have_owners
    # we have to use collection participants because the association may not exist until after
    # the collection is saved
    errors.add(:base, ts("Collection has no valid owners.")) if (self.collection_participants + (self.parent ? self.parent.collection_participants : [])).select(&:is_owner?)
      .empty?
  end

  validate :collection_depth
  def collection_depth
    errors.add(:base, ts("Sorry, but %{name} is a subcollection, so it can't also be a parent collection.", name: parent.name)) if self.parent&.parent || (self.parent && !self.children.empty?) || (!self.children.empty? && !self.children.collect(&:children).flatten.empty?)
  end

  validate :parent_exists
  def parent_exists
    errors.add(:base, ts("We couldn't find a collection with name %{name}.", name: parent_name)) unless parent_name.blank? || Collection.find_by(name: parent_name)
  end

  validate :parent_is_allowed
  def parent_is_allowed
    if parent
      if parent == self
        errors.add(:base, ts("You can't make a collection its own parent."))
      elsif parent_id_changed? && !parent.user_is_maintainer?(User.current_user)
        errors.add(:base, ts("You have to be a maintainer of %{name} to make a subcollection.", name: parent.name))
      end
    end
  end

  validates :name, presence: { message: ts("Please enter a name for your collection.") }
  validates :name, uniqueness: { message: ts("Sorry, that name is already taken. Try again, please!") }
  validates :name,
            length: { minimum: ArchiveConfig.TITLE_MIN,
                      too_short: ts("must be at least %{min} characters long.", min: ArchiveConfig.TITLE_MIN) }
  validates :name,
            length: { maximum: ArchiveConfig.TITLE_MAX,
                      too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.TITLE_MAX) }
  validates :name,
            format: { message: ts("must begin and end with a letter or number; it may also contain underscores. It may not contain any other characters, including spaces."),
                      with: /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/ }
  validates :icon_alt_text, length: { allow_blank: true, maximum: ArchiveConfig.ICON_ALT_MAX,
                                      too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.ICON_ALT_MAX) }
  validates :icon_comment_text, length: { allow_blank: true, maximum: ArchiveConfig.ICON_COMMENT_MAX,
                                          too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.ICON_COMMENT_MAX) }

  validates :email, email_format: { allow_blank: true }

  validates :title, presence: { message: ts("Please enter a title to be displayed for your collection.") }
  validates :title,
            length: { minimum: ArchiveConfig.TITLE_MIN,
                      too_short: ts("must be at least %{min} characters long.", min: ArchiveConfig.TITLE_MIN) }
  validates :title,
            length: { maximum: ArchiveConfig.TITLE_MAX,
                      too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.TITLE_MAX) }
  validate :no_reserved_strings
  def no_reserved_strings
    errors.add(:title, ts("^Sorry, the ',' character cannot be in a collection Display Title.")) if
      title.match(/,/)
  end

  # return title.html_safe to overcome escaping done by sanitiser
  def title
    self[:title].try(:html_safe)
  end

  validates :description,
            length: { allow_blank: true,
                      maximum: ArchiveConfig.SUMMARY_MAX,
                      too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.SUMMARY_MAX) }

  validates :header_image_url, format: { allow_blank: true, with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: ts("is not a valid URL.") }
  validates :header_image_url, format: { allow_blank: true, with: /\A\S+\.(png|gif|jpg)\z/, message: ts("can only point to a gif, jpg, or png file.") }

  validates :tags_after_saving,
            length: { maximum: ArchiveConfig.COLLECTION_TAGS_MAX,
                      message: "^Sorry, a collection can only have %{count} tags." }

  scope :top_level, -> { where(parent_id: nil) }
  scope :closed, -> { joins(:collection_preference).where(collection_preferences: { closed: true }) }
  scope :not_closed, -> { joins(:collection_preference).where(collection_preferences: { closed: false }) }
  scope :moderated, -> { joins(:collection_preference).where(collection_preferences: { moderated: true }) }
  scope :unmoderated, -> { joins(:collection_preference).where(collection_preferences: { moderated: false }) }
  scope :unrevealed, -> { joins(:collection_preference).where(collection_preferences: { unrevealed: true }) }
  scope :anonymous, -> { joins(:collection_preference).where(collection_preferences: { anonymous: true }) }
  scope :no_challenge, -> { where(challenge_type: nil) }
  scope :gift_exchange, -> { where(challenge_type: "GiftExchange") }
  scope :prompt_meme, -> { where(challenge_type: "PromptMeme") }
  scope :name_only, -> { select("collections.name") }
  scope :by_title, -> { order(:title) }
  scope :for_blurb, -> { includes(:parent, :moderators, :children, :collection_preference, owners: [:user]).with_attached_icon }

  def cleanup_url
    self.header_image_url = Addressable::URI.heuristic_parse(self.header_image_url) if self.header_image_url
  end

  # Get only collections with running challenges
  def self.signup_open(challenge_type)
    case challenge_type
    when "PromptMeme"
      not_closed.where(challenge_type: challenge_type)
        .joins("INNER JOIN prompt_memes on prompt_memes.id = challenge_id").where("prompt_memes.signup_open = 1")
        .where("prompt_memes.signups_close_at > ?", Time.zone.now).order("prompt_memes.signups_close_at DESC")
    when "GiftExchange"
      not_closed.where(challenge_type: challenge_type)
        .joins("INNER JOIN gift_exchanges on gift_exchanges.id = challenge_id").where("gift_exchanges.signup_open = 1")
        .where("gift_exchanges.signups_close_at > ?", Time.zone.now).order("gift_exchanges.signups_close_at DESC")
    end
  end

  scope :with_name_like, lambda { |name|
    where("collections.name LIKE ?", "%#{name}%")
      .limit(10)
  }

  scope :with_title_like, lambda { |title|
    where("collections.title LIKE ?", "%#{title}%")
  }

  scope :with_item_count, lambda {
    select("collections.*, count(distinct collection_items.id) as item_count")
      .joins("left join collections child_collections on child_collections.parent_id = collections.id
           left join collection_items on ( (collection_items.collection_id = child_collections.id OR collection_items.collection_id = collections.id)
                                     AND collection_items.user_approval_status = 1
                                     AND collection_items.collection_approval_status = 1)")
      .group("collections.id")
  }

  def to_param
    name_was
  end

  # Change membership of collection(s) from a particular pseud to the orphan account
  def self.orphan(pseuds, collections, default: true)
    pseuds.each do |pseud|
      collections.each do |collection|
        if pseud && collection && collection.owners.include?(pseud)
          orphan_pseud = default ? User.orphan_account.default_pseud : User.orphan_account.pseuds.find_or_create_by(name: pseud.name)
          pseud.change_membership(collection, orphan_pseud)
        end
      end
    end
  end

  ## AUTOCOMPLETE
  # set up autocomplete and override some methods
  include AutocompleteSource

  def autocomplete_search_string
    "#{name} #{title}"
  end

  def autocomplete_search_string_before_last_save
    "#{name_before_last_save} #{title_before_last_save}"
  end

  def autocomplete_prefixes
    ["autocomplete_collection_all",
     "autocomplete_collection_#{closed? ? 'closed' : 'open'}"]
  end

  def autocomplete_score
    all_items.approved_by_collection.approved_by_user.count
  end
  ## END AUTOCOMPLETE

  def parent_name=(name)
    @parent_name = name
    self.parent = Collection.find_by(name: name)
  end

  def parent_name
    @parent_name || (self.parent ? self.parent.name : "")
  end

  def all_owners
    (self.owners + (self.parent ? self.parent.owners : [])).uniq
  end

  def all_moderators
    (self.moderators + (self.parent ? self.parent.moderators : [])).uniq
  end

  def all_members
    (self.members + (self.parent ? self.parent.members : [])).uniq
  end

  def all_posting_participants
    (self.posting_participants + (self.parent ? self.parent.posting_participants : [])).uniq
  end

  def all_participants
    (self.participants + (self.parent ? self.parent.participants : [])).uniq
  end

  def all_items
    CollectionItem.where(collection_id: ([self.id] + self.children.pluck(:id)))
  end

  def maintainers
    self.all_owners + self.all_moderators
  end

  def user_is_owner?(user)
    user && user != false && !(user.pseuds & self.all_owners).empty?
  end

  def user_is_moderator?(user)
    user && user != false && !(user.pseuds & self.all_moderators).empty?
  end

  def user_is_maintainer?(user)
    user && user != false && !(user.pseuds & (self.all_moderators + self.all_owners)).empty?
  end

  def user_is_participant?(user)
    user && user != false && !get_participating_pseuds_for_user(user).empty?
  end

  def user_is_posting_participant?(user)
    user && user != false && !(user.pseuds & self.all_posting_participants).empty?
  end

  def get_participating_pseuds_for_user(user)
    (user && user != false) ? user.pseuds & self.all_participants : []
  end

  def get_participants_for_user(user)
    return [] unless user

    CollectionParticipant.in_collection(self).for_user(user)
  end

  def assignment_notification
    self.collection_profile.assignment_notification || (parent ? parent.collection_profile.assignment_notification : "")
  end

  def gift_notification
    self.collection_profile.gift_notification || (parent ? parent.collection_profile.gift_notification : "")
  end

  def moderated?() = self.collection_preference.moderated

  def closed?() = self.collection_preference.closed

  def unrevealed?() = self.collection_preference.unrevealed

  def anonymous?() = self.collection_preference.anonymous

  def challenge?() = !self.challenge.nil?

  def gift_exchange?
    self.challenge_type == "GiftExchange"
  end

  def prompt_meme?
    self.challenge_type == "PromptMeme"
  end

  def maintainers_list
    self.maintainers.collect(&:user).flatten.uniq
  end

  def collection_email
    return self.email if self.email.present?
    return parent.email if parent && parent.email.present?
  end

  def notify_maintainers_assignments_sent
    subject = I18n.t("user_mailer.collection_notification.assignments_sent.subject")
    message = I18n.t("user_mailer.collection_notification.assignments_sent.complete")
    if self.collection_email.present?
      UserMailer.collection_notification(self.id, subject, message, self.collection_email).deliver_later
    else
      # if collection email is not set and collection parent email is not set, loop through maintainers and send each a notice via email
      self.maintainers_list.each do |user|
        I18n.with_locale(user.preference.locale.iso) do
          translated_subject = I18n.t("user_mailer.collection_notification.assignments_sent.subject")
          translated_message = I18n.t("user_mailer.collection_notification.assignments_sent.complete")
          UserMailer.collection_notification(self.id, translated_subject, translated_message, user.email).deliver_later
        end
      end
    end
  end

  def notify_maintainers_challenge_default(challenge_assignment, assignments_page_url)
    if self.collection_email.present?
      subject = I18n.t("user_mailer.collection_notification.challenge_default.subject", offer_byline: challenge_assignment.offer_byline)
      message = I18n.t("user_mailer.collection_notification.challenge_default.complete", offer_byline: challenge_assignment.offer_byline, request_byline: challenge_assignment.request_byline, assignments_page_url: assignments_page_url)
      UserMailer.collection_notification(self.id, subject, message, self.collection_email).deliver_later
    else
      # if collection email is not set and collection parent email is not set, loop through maintainers and send each a notice via email
      self.maintainers_list.each do |user|
        I18n.with_locale(user.preference.locale.iso) do
          translated_subject = I18n.t("user_mailer.collection_notification.challenge_default.subject", offer_byline: challenge_assignment.offer_byline)
          translated_message = I18n.t("user_mailer.collection_notification.challenge_default.complete", offer_byline: challenge_assignment.offer_byline, request_byline: challenge_assignment.request_byline, assignments_page_url: assignments_page_url)
          UserMailer.collection_notification(self.id, translated_subject, translated_message, user.email).deliver_later
        end
      end
    end
  end

  include AsyncWithResque
  @queue = :collection

  def reveal!
    async(:reveal_collection_items)
  end

  def reveal_authors!
    async(:reveal_collection_item_authors)
  end

  def reveal_collection_items
    approved_collection_items.each { |collection_item| collection_item.update_attribute(:unrevealed, false) }
    send_reveal_notifications
  end

  def reveal_collection_item_authors
    approved_collection_items.each { |collection_item| collection_item.update_attribute(:anonymous, false) }
  end

  def send_reveal_notifications
    approved_collection_items.each(&:notify_of_reveal)
  end

  def self.sorted_and_filtered(sort, filters, page)
    pagination_args = { page: page }

    # build up the query with scopes based on the options the user specifies
    query = Collection.top_level

    if filters[:title].present?
      # we get the matching collections out of autocomplete and use their ids
      ids = Collection.autocomplete_lookup(search_param: filters[:title],
                                           autocomplete_prefix: (if filters[:closed].blank?
                                                                   "autocomplete_collection_all"
                                                                 else
                                                                   (filters[:closed] ? "autocomplete_collection_closed" : "autocomplete_collection_open")
                                                                 end)).map { |result| Collection.id_from_autocomplete(result) }
      query = query.where(collections: { id: ids })
    elsif filters[:closed].present?
      query = (filters[:closed] == "true" ? query.closed : query.not_closed)
    end
    query = (filters[:moderated] == "true" ? query.moderated : query.unmoderated) if filters[:moderated].present?
    if filters[:challenge_type].present?
      case filters[:challenge_type]
      when "gift_exchange"
        query = query.gift_exchange
      when "prompt_meme"
        query = query.prompt_meme
      when "no_challenge"
        query = query.no_challenge
      end
    end
    query = query.order(sort).for_blurb

    if filters[:fandom].blank?
      query.paginate(pagination_args)
    else
      fandom = Fandom.find_by_name(filters[:fandom])
      if fandom
        (fandom.approved_collections & query).paginate(pagination_args)
      else
        []
      end
    end
  end

  # Delete current icon (thus reverting to archive default icon)
  def delete_icon=(value)
    @delete_icon = !value.to_i.zero?
  end

  def delete_icon
    !!@delete_icon
  end
  alias delete_icon? delete_icon

  def clear_icon
    return unless delete_icon?

    self.icon.purge
    self.icon_alt_text = nil
    self.icon_comment_text = nil
  end
end
