module Collectible

  def self.included(collectible)
    collectible.class_eval do

      has_many :collection_items, :as => :item, :dependent => :destroy
      accepts_nested_attributes_for :collection_items, :allow_destroy => true
      has_many :approved_collection_items, :class_name => "CollectionItem", :as => :item,
        :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]

      has_many :collections, :through => :collection_items
      has_many :approved_collections, :through => :collection_items, :source => :collection,
        :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]
    end
  end

  # Set an item's collections based on a list of collection names
  # Don't delete all existing collections, or else items in closed collections
  # can't be edited
  def collection_names=(new_collection_names)
    names = new_collection_names.split(',').map{ |name| name.strip }
    to_add = Collection.where(:name => names)
    (self.collections - to_add).each do |c|
      self.collections.delete(c)
    end
    (to_add - self.collections).each do |c|
      self.collections << c
    end
    (names - to_add.map{ |c| c.name }).each do |name|
      unless name.blank?
        self.errors.add(:base, ts("We couldn't find a collection with the name %{name}. Make sure you are using the one-word name, and not the title?", :name => name.strip))
      end
    end
  end

  def add_to_collection(collection)
    if collection && !self.collections.include?(collection)
      self.collections << collection
    end
  end

  def add_to_collection!(collection)
    add_to_collection(collection)
    save
  end

  def remove_from_collection!(collection)
    if collection && self.collections.include?(collection)
      self.collections -= [collection]
    end
  end

  def remove_from_collection!(collection)
    remove_from_collection(collection)
    save
  end

  def collection_names
    self.collections.collect(&:name).join(",")
  end

end
