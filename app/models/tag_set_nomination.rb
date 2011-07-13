class TagSetNomination < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :owned_tag_set
  
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
      tagcount = nominated_tags(tag_type).count
      limit = self.owned_tag_set.send("#{tag_type}_nomination_limit")
      if tagcount > limit
        errors.add(:base, ts("^You can only nominate %{limit} #{tag_type} tags.", :limit => limit))
      end
    end 
  end
  
  def self.owned_by(user = User.current_user)
    select("DISTINCT tag_set_nominations.*").
    joins(:pseud => :user).
    where("users.id = ?", user.id)
  end

  def self.for_tag_set(tag_set)
    where(:owned_tag_set_id => tag_set.id)
  end

  def nominated_tags(tag_type = "fandom")
    tagnames = self.send("#{tag_type}_nominations")
    if tagnames.blank?
      return []
    else
      return tagnames.split(ArchiveConfig.DELIMITER_FOR_INPUT)
    end
  end
  
end
