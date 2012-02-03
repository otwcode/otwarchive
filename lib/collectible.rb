module Collectible

  def self.included(collectible)
    collectible.class_eval do

      has_many :collection_items, :as => :item, :dependent => :destroy, :inverse_of => :item
      accepts_nested_attributes_for :collection_items, :allow_destroy => true
      has_many :approved_collection_items, :class_name => "CollectionItem", :as => :item,
        :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]

      has_many :collections, :through => :collection_items
      has_many :approved_collections, :through => :collection_items, :source => :collection,
        :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]
    end
  end
  
  def collections_to_add=(collection_names)
    names = collection_names.split(',').reject {|name| name.blank?}.map { |name| name.strip }.each do |name|
      c = Collection.find_by_name(name)
      errors.add(:base, ts("We couldn't find the collection {{name}}.", :name => name)) and return if c.nil?
      errors.add(:base, ts("The collection {{name}} is not currently open.", :name => name)) and return if (c.closed? && !c.user_is_maintainer?(User.current_user))
      unless self.collections.include?(c)
        self.collections << c
      end
    end
  end
  
  def collections_to_remove=(collection_ids)
    collection_ids.reject {|id| id.blank?}.map {|id| id.strip}.each do |id|
      c = Collection.find(id) || nil
      if c && self.collections.include?(c)
        self.collections -= [c]
      end
    end
  end 
  
  def collections_to_add; nil; end
  def collections_to_remove; nil; end

  # Set an item's collections based on a list of collection names
  # Don't delete all existing collections, or else items in closed collections
  # can't be edited
  def collection_names=(new_collection_names)
    names = new_collection_names.split(',').map{ |name| name.strip }
    new_collections = Collection.where(:name => names)
    missing = names - new_collections.value_of(:name)
    to_add = new_collections - self.collections
    to_remove = self.collections - new_collections
    to_remove.each do |c|
      self.collections.delete(c)
    end
    to_add.each do |c|
      self.collections << c
    end
    unless missing.blank?
      error = missing.size == 1 ? 
        ts("We couldn't find a collection with the name %{name}. ", :name => missing.first) : 
        ts("We couldn't find the collections named %{names}. ", :names => missing.to_sentence)
      error += ts("Make sure you are using the one-word name, and not the title?")
      self.errors.add(:base, error)
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
    @collection_names ? @collection_names : self.collections.collect(&:name).join(",")
  end

end
