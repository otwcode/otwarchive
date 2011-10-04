class TagSetNomination < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :owned_tag_set, :inverse_of => :tag_set_nominations
  
  has_many :tag_nominations, :dependent => :destroy, :inverse_of => :tag_set_nomination
  has_many :fandom_nominations, :dependent => :destroy, :inverse_of => :tag_set_nomination
  has_many :character_nominations, :dependent => :destroy, :inverse_of => :tag_set_nomination
  has_many :relationship_nominations, :dependent => :destroy, :inverse_of => :tag_set_nomination
  has_many :freeform_nominations, :dependent => :destroy, :inverse_of => :tag_set_nomination

  accepts_nested_attributes_for :fandom_nominations, :character_nominations, :relationship_nominations, :freeform_nominations, {
    :allow_destroy => true,
    :reject_if => proc { |attrs| attrs[:tagname].blank? }
  }
  
  validates_presence_of :owned_tag_set_id
  validates_presence_of :pseud_id

  validates_uniqueness_of :owned_tag_set_id, :scope => [:pseud_id], :message => ts("You have already submitted nominations for that tag set. Try editing them instead.")
  
  validate :can_nominate
  def can_nominate
    unless owned_tag_set.nominated
      errors.add(:base, ts("%{title} is not currently accepting nominations.", :title => owned_tag_set.title))
    end
  end
  
  validate :nomination_limits
  def nomination_limits
    TagSet::TAG_TYPES_INITIALIZABLE.each do |tag_type|    
      limit = self.owned_tag_set.send("#{tag_type}_nomination_limit")
      if count_by_fandom?(tag_type)
        if self.fandom_nominations.any? {|fandom_nom| fandom_nom.send("#{tag_type}_nominations").try(:count) > limit}
          errors.add(:base, ts("You can only nominate %{limit} #{tag_type} tags per fandom.", :limit => limit))
        end
      else
        count = self.send("#{tag_type}_nominations").count
        errors.add(:base, ts("You can only nominate %{limit} #{tag_type} tags", :limit => limit)) if count > limit
      end
    end 
  end

  # This makes sure a single user doesn't nominate the same tagname twice
  validate :require_unique_tagnames
  def require_unique_tagnames
    tagnames = []
    %w(fandom character relationship freeform).each do |nomtype|
      tagnames += self.send("#{nomtype}_nominations").map(&:tagname).reject {|t| t.blank?}
    end
    duplicates = tagnames.group_by {|tagname| tagname}.select {|k,v| v.size > 1}.keys
    errors.add(:base, ts("You seem to be trying to nominate %{duplicates} more than once.", :duplicates => duplicates.join(', '))) unless duplicates.empty?
  end

  # # This makes sure no tagnames are nominated for different parents in this tag set
  # validate :require_unique_tagname_with_parent
  # def require_unique_tagname_with_parent
  #   %w(fandom character relationship freeform).each do |nomtype|
  #     self.send("#{nomtype}_nominations").each do |nom|
  #       query = TagNomination.for_tag_set(self.owned_tag_set).where(:tagname => nom.tagname).where("parent_tagname != ?", (nom.get_parent_tagname || ''))
  #       # let people change their own!
  #       query = query.where("tag_nominations.id != ?", nom.id) if !(nom.new_record?)
  #       if query.exists?
  #         errors.add(:base, ts("Someone else has already nominated %{tagname} for this set but in a different fandom. Please be more specific.", :tagname => nom.tagname))
  #       end
  #     end
  #   end
  # end
  # 
  # Have NONE of the nominations been reviewed?
  def unreviewed?
    TagSet::TAG_TYPES_INITIALIZABLE.each do |tag_type|
      return false if self.send("#{tag_type}_nominations").any? {|tn| tn.reviewed?}
    end
    return true
  end

  # Have ALL the nominations been reviewed?
  def reviewed?
    TagSet::TAG_TYPES_INITIALIZABLE.each do |tag_type|
      return false if self.send("#{tag_type}_nominations").any? {|tn| tn.unreviewed?}
    end
    return true
  end

  
  def count_by_fandom?(tag_type)
    %w(character relationship).include?(tag_type) && self.owned_tag_set.fandom_nomination_limit > 0
  end
  
  def self.owned_by(user = User.current_user)
    select("DISTINCT tag_set_nominations.*").
    joins(:pseud => :user).
    where("users.id = ?", user.id)
  end

  def self.for_tag_set(tag_set)
    where(:owned_tag_set_id => tag_set.id)
  end

  def nominated_tags(tag_type = "fandom", index = -1)
    if count_by_fandom?(tag_type)
      if index == -1
        # send ALL the collected char/relationship nominations per fandom
        self.fandom_nominations.collect(&("#{tag_type}_nominations".to_sym)).flatten
      else
        # send just the nominations for this fandom
        self.fandom_nominations[index].send("#{tag_type}_nominations")
      end
    else
       self.send("#{tag_type}_nominations")
    end
  end
  
  def process(tag_set_id)
    TagSet::TAG_TYPES_INITIALIZABLE.each {|tag_type| self.send("#{tag_type}_nominations").each {|nom| nom.process}}
  end
  
end
