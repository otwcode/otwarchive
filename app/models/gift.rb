class Gift < ActiveRecord::Base
  NAME_LENGTH_MAX = 100

  belongs_to :work
  belongs_to :pseud
  
  validates_length_of :recipient_name,
    :maximum => NAME_LENGTH_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => NAME_LENGTH_MAX),
    :allow_blank => true

  validates_format_of :recipient_name, 
    :message => ts("must contain at least one letter or number."),
    :with => /[a-zA-Z0-9]/,
    :allow_blank => true
    
  validate :has_name_or_pseud
  def has_name_or_pseud
    unless self.pseud || !self.recipient_name.blank?
      errors.add(:base, ts("A gift must have a recipient specified."))
    end
  end

  scope :for_pseud, lambda {|pseud| where("pseud_id = ?", pseud.id)}
    
  scope :for_user, lambda {|user| where("pseud_id IN (?)", user.pseuds.collect(&:id).flatten)}

  scope :for_recipient_name, lambda {|name| where("recipient_name = ?", name)}
  
  scope :for_name_or_byline, lambda {|name| where("recipient_name = ? OR pseud_id = ?", 
                                                  name, 
                                                  Pseud.parse_byline(name, :assume_matching_login => true).first)}
  
  scope :in_collection, lambda {|collection|
    select("DISTINCT gifts.*").
    joins({:work => :collection_items}).
    where("collection_items.collection_id = ?", collection.id)
  }
  
  scope :name_only, :select => :recipient_name
  
  scope :include_pseuds, includes(:work => [:pseuds])

  def recipient=(new_recipient_name)
    self.pseud = Pseud.parse_byline(new_recipient_name, :assume_matching_login => true).first
    self.recipient_name = pseud ? nil : new_recipient_name
  end

  def recipient
    pseud ? pseud.byline : recipient_name
  end

end
