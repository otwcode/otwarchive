class Gift < ActiveRecord::Base
  NAME_LENGTH_MAX = 100

  belongs_to :work
  
  validates_presence_of :recipient_name

  validates_length_of :recipient_name,
    :maximum => NAME_LENGTH_MAX,
    :too_long => t('gift.recipient_name_too_long', :default => "must be less than {{max}} characters long.", :max => NAME_LENGTH_MAX)

  validates_format_of :recipient_name, 
    :message => t('gift.name_no_letters_or_numbers', :default => 'must contain at least one letter or number.'),
    :with => /[a-zA-Z0-9]/

  named_scope :for_pseud, lambda {|pseud| {:conditions => ["recipient_name = ?", pseud.byline]}}
  
  named_scope :for_user, lambda {|user| {:conditions => ["recipient_name IN (?)", user.pseuds.collect(&:byline).flatten]}}
  
  named_scope :for_recipient, lambda {|name| {:conditions => ["recipient_name = ?", name]}}
  
  named_scope :in_collection, lambda {|collection|
    {
      :select => "DISTINCT gifts.*",
      :joins => "INNER JOIN works ON (gifts.work_id = works.id) 
                 INNER JOIN collection_items ON (collection_items.item_id = works.id AND collection_items.item_type = 'Work')",
      :conditions => ["collection_items.collection_id = ?", collection.id]
    }
  }
  
  named_scope :name_only, :select => :recipient_name
  
  named_scope :include_pseuds, :include => [{:work => :pseuds}]

end
