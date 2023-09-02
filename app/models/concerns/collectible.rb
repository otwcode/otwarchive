module Collectible
  extend ActiveSupport::Concern

  included do
    has_many :collection_items, as: :item, inverse_of: :item, autosave: true, dependent: :destroy

    has_many :approved_collection_items, -> { approved_by_both },
             class_name: "CollectionItem", as: :item, inverse_of: :item, dependent: :destroy
    has_many :user_approved_collection_items, -> { approved_by_user },
             class_name: "CollectionItem", as: :item, inverse_of: :item, dependent: :destroy

    has_many :collections,
             through: :collection_items,
             dependent: :destroy
    has_many :approved_collections,
             through: :approved_collection_items,
             source: :collection,
             dependent: :destroy
    has_many :user_approved_collections,
             through: :user_approved_collection_items,
             source: :collection,
             dependent: :destroy
    has_many :rejected_collections,
             -> { CollectionItem.rejected_by_user },
             through: :collection_items,
             source: :collection,
             dependent: :destroy

    # Note: this scope includes the items in the children of the specified collection
    scope :in_collection, lambda { |collection|
      distinct.joins(:approved_collection_items).merge(collection.all_items)
    }

    after_validation :set_anon_unrevealed
  end

  # The collection items that will remain after this item has been saved.
  def collection_items_after_saving
    collection_items
      .reject(&:marked_for_destruction?)
      .reject(&:destroyed?)
  end

  # The collections that this item will be approved in after the item has been
  # saved:
  def approved_collections_after_saving
    if collection_items.target.empty?
      approved_collections.to_a
    else
      collection_items_after_saving.select(&:approved?).map(&:collection)
    end
  end

  # All collections that this item will be included in (including rejected and
  # unreviewed collections) after the item has been saved:
  def collections_after_saving
    if collection_items.target.empty?
      collections.to_a
    else
      collection_items_after_saving.map(&:collection)
    end
  end

  # Set which collections this item should be in after saving:
  def collections_after_saving=(collections)
    assign_through_association(collection_items, :collection, collections)
  end

  # Add collections with a comma-separated list of names:
  def collections_to_add=(names)
    self.collections_after_saving += parse_collection_names(names)
  end

  # The collection names that are about to be added:
  def collections_to_add
    collection_items_after_saving
      .select(&:new_record?)
      .map(&:collection)
      .map(&:name)
      .join(",")
  end

  # Remove collections by ID:
  def collections_to_remove=(ids)
    collections = Collection.find(ids.reject(&:blank?).map(&:to_i))
    self.collections_after_saving -= collections
  end

  # The collection IDs to be removed:
  def collections_to_remove
    collection_items.select(&:marked_for_destruction?).map(&:collection_id)
  end

  # Assign this item's collections by a comma-separated list of names:
  def collection_names=(names)
    self.collections_after_saving = parse_collection_names(names)
  end

  # Returns the collections that this item will have after saving as a
  # comma-separated list of names:
  def collection_names
    collections_after_saving.map(&:name).join(",")
  end

  # Add the given collection and immediately save the resulting collection item:
  def add_to_collection(collection)
    collection_item = collection_items.find { |ci| ci.collection == collection }
    collection_item ||= collection_items.build(collection: collection)
    collection_item.unmark_for_destruction

    # If we're a new record, we don't need to save the collection item
    # immediately, since it'll get saved when we're saved. And we don't need to
    # save the collection item if it's already persisted. But otherwise, we do
    # want to save it:
    new_record? || collection_item.persisted? || collection_item.save
  end

  #### UNREVEALED/ANONYMOUS

  # Set the anonymous/unrevealed status of the collectible based on its
  # collection items.
  def set_anon_unrevealed
    return unless has_attribute?(:anonymous) && has_attribute?(:unrevealed)

    if collection_items.target.empty?
      relevant = user_approved_collection_items

      self.anonymous = relevant.anonymous.exists?
      self.unrevealed = relevant.unrevealed.exists?
    else
      relevant = collection_items_after_saving
        .select(&:approved_by_user?)

      self.anonymous = relevant.any?(&:anonymous?)
      self.unrevealed = relevant.any?(&:unrevealed?)
    end
  end

  private

  # Given a comma-separated list of names, return a list of collections.
  #
  # For any names that can't be found, returns an unsaved collection with the
  # desired name, so that we can include that name in error messages.
  def parse_collection_names(names)
    names.split(",").map(&:strip).reject(&:blank?).map do |name|
      Collection.find_or_initialize_by(name: name)
    end
  end
end
