class TagSetNomination < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :owned_tag_set
  
  has_many :fandom_nominations, :dependent => :destroy
  accepts_nested_attributes_for :fandom_nominations, :allow_destroy => true

  has_many :character_nominations, :dependent => :destroy
  accepts_nested_attributes_for :character_nominations, :allow_destroy => true

  has_many :relationship_nominations, :dependent => :destroy
  accepts_nested_attributes_for :relationship_nominations, :allow_destroy => true

  has_many :freeform_nominations, :dependent => :destroy
  accepts_nested_attributes_for :freeform_nominations, :allow_destroy => true
  
  validates_presence_of :owned_tag_set_id
  validates_presence_of :pseud_id

  validates_uniqueness_of :owned_tag_set_id, :scope => [:pseud_id], :message => ts("^You have already submitted nominations for that tag set. Try editing them instead.")
  
  validate :can_nominate
  def can_nominate
    unless owned_tag_set.nominated
      errors.add(:base, ts("^%{title} is not currently accepting nominations.", :title => owned_tag_set.title))
    end
  end
  
  validate :tag_validity
  def tag_validity
    TagSet::TAG_TYPES_INITIALIZABLE.each do |tag_type| 
      nominated_tags(tag_type).each do |tagname|
        # we are duplicating the tag.rb name validations here
        if tagname.length > ArchiveConfig.TAG_MAX 
          errors.add(:base, ts("^The tag %{tagname} is too long.", :tagname => tagname))
        elsif !tagname.match(/\A[^,*<>^{}=`\\%]+\z/)
          errors.add(:base, ts("^A tag cannot contain the following restricted characters: , ^ * < > { } = ` \\ %"))
        elsif (tag = Tag.find_by_name(tagname)) && tag.type != tag_type.classify
          errors.add(:base, ts("The tag %{tagname} is already in the archive but as a #{tag.type} tag.", :tagname => tagname))
        end
      end
    end
  end

  validate :nomination_limits
  def nomination_limits
    TagSet::TAG_TYPES_INITIALIZABLE.each do |tag_type|    
      limit = self.owned_tag_set.send("#{tag_type}_nomination_limit")
      over_limit = false
      if count_by_fandom?(tag_type)
        self.send("#{tag_type}_nominations").try(:count).times do |i|
          if nominated_tags(tag_type, i).count > limit
            over_limit = true
            break
          end
        end
      else  
        tagcount = nominated_tags(tag_type).count
        fandom_tagcount = tagcount if tag_type == "fandom"
        over_limit = tagcount > limit
      end
      if over_limit
        errors.add(:base, ts("^You can only nominate %{limit} #{tag_type} tags", :limit => limit) + 
        	    count_by_fandom?(tag_type) ? ts(" per fandom.") : ".")
      end
    end 
  end
  
  validate :no_tags_without_fandoms
  def no_tags_without_fandoms
    %w(character relationship).each do |tag_type|
      if count_by_fandom?(tag_type)
        self.send("#{tag_type}_nominations").try(:count).times do |i|
          if nominated_tags(tag_type, i).count > 0 && nominated_tags("fandom", i).count == 0
            errors.add(:base, ts("^You haven't specified the fandom for some of your nominated #{tag_type} tags."))
            break
          end
        end
      end
    end
  end
  
  def count_by_fandom?(tag_type)
    fandom_limit = self.owned_tag_set.fandom_nomination_limit
    %w(character relationship).include?(tag_type) && fandom_limit > 0
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
    tag_type == "freeform" ? self.freeform_nominations : 
      (tag_type == "fandom" ? self.fandom_nominations :
        (index == -1 ? self.send("#{tag_type}_nominations") :
          self.send("#{tag_type}_nominations").where(:fandom_index => index)))
  end
  

end
