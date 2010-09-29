class Gift < ActiveRecord::Base
  NAME_LENGTH_MAX = 100

  belongs_to :work
  belongs_to :pseud
  
  validates_length_of :recipient_name,
    :maximum => NAME_LENGTH_MAX,
    :too_long => t('gift.recipient_name_too_long', :default => "must be less than %{max} characters long.", :max => NAME_LENGTH_MAX),
    :allow_blank => true

  validates_format_of :recipient_name, 
    :message => t('gift.name_no_letters_or_numbers', :default => 'must contain at least one letter or number.'),
    :with => /[a-zA-Z0-9]/,
    :allow_blank => true
    
  validate :has_name_or_pseud
  def has_name_or_pseud
    unless self.pseud || !self.recipient_name.blank?
      errors.add_to_base("A gift must have a recipient specified.")
    end
  end

  scope :for_pseud, lambda {|pseud| {:conditions => ["pseud_id = ?", pseud.id]}}
  
  scope :for_user, lambda {|user| {:conditions => ["pseud_id IN (?)", user.pseuds.collect(&:id).flatten]}}

  scope :for_recipient_name, lambda {|name| {:conditions => ["recipient_name = ?", name]}}
  
  scope :in_collection, lambda {|collection|
    {
      :select => "DISTINCT gifts.*",
      :joins => "INNER JOIN works ON (gifts.work_id = works.id) 
                 INNER JOIN collection_items ON (collection_items.item_id = works.id AND collection_items.item_type = 'Work')",
      :conditions => ["collection_items.collection_id = ?", collection.id]
    }
  }
  
  scope :name_only, :select => :recipient_name
  
  scope :include_pseuds, :include => [{:work => :pseuds}]

  def recipient=(new_recipient_name)
    self.pseud = Pseud.parse_byline(new_recipient_name, :assume_matching_login => true).first
    self.recipient_name = pseud ? nil : new_recipient_name
  end

  def recipient
    pseud ? pseud.byline : recipient_name
  end

end
