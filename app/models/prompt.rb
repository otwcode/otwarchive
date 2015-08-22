class Prompt < ActiveRecord::Base

  # -1 represents all matching
  ALL = -1

  # number of checkbox options to keep visible by default in form
  OPTIONS_TO_SHOW = 3

  # maximum number of options to allow to be shown via checkboxes
  MAX_OPTIONS_FOR_CHECKBOXES = 10
  
  # ASSOCIATIONS

  belongs_to :collection
  belongs_to :pseud
  has_one :user, :through => :pseud

  belongs_to :challenge_signup, :touch => true, :inverse_of => :prompts

  belongs_to :tag_set, :dependent => :destroy
  accepts_nested_attributes_for :tag_set
  has_many :tags, :through => :tag_set

  belongs_to :optional_tag_set, :class_name => "TagSet", :dependent => :destroy
  accepts_nested_attributes_for :optional_tag_set
  has_many :optional_tags, :through => :optional_tag_set, :source => :tag
  
  has_many :request_claims, :class_name => "ChallengeClaim", :foreign_key => 'request_prompt_id'
  
  # SCOPES
  
  scope :claimed, joins("INNER JOIN challenge_claims on prompts.id = challenge_claims.request_prompt_id")
  
  scope :in_collection, lambda {|collection| where(collection_id: collection.id) }
  
  scope :unused, {:conditions => {:used_up => false}}
  
  scope :with_tag, lambda { |tag| 
    joins("JOIN set_taggings ON set_taggings.tag_set_id = prompts.tag_set_id").
    where("set_taggings.tag_id = ?", tag.id) 
  }
  
  # CALLBACKS

  before_destroy :clear_claims
  def clear_claims
    # remove this prompt reference from any existing assignments
    request_claims.each {|claim| claim.destroy}
  end

  # VALIDATIONS
  
  attr_protected :description_sanitizer_version

  validates_presence_of :collection_id
  
  validates_presence_of :challenge_signup
  before_save :set_pseud
  def set_pseud
    unless self.pseud
      self.pseud = self.challenge_signup.pseud
    end
    true
  end

  # based on the prompt restriction
  validates_presence_of :url, :if => :url_required?
  validates_presence_of :description, :if => :description_required?
  validates_presence_of :title, :if => :title_required?
  def url_required?
    (restriction = get_prompt_restriction) && restriction.url_required
  end
  def description_required?
    (restriction = get_prompt_restriction) && restriction.description_required
  end
  validates_length_of :description,
    :maximum => ArchiveConfig.NOTES_MAX,
    :too_long => ts("must be less than %{max} letters long.", :max => ArchiveConfig.NOTES_MAX)
  def title_required?
    (restriction = get_prompt_restriction) && restriction.title_required
  end
  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> ts("must be less than %{max} letters long.", :max => ArchiveConfig.TITLE_MAX)

  validates :url, :url_format => {:allow_blank => true} # we validate the presence above, conditionally

  before_validation :cleanup_url
  def cleanup_url
    self.url = reformat_url(self.url) if self.url
  end

  validate :correct_number_of_tags
  def correct_number_of_tags
    prompt_type = self.class.name
    restriction = get_prompt_restriction
    if restriction
      # make sure tagset has no more/less than the required/allowed number of tags of each type
      TagSet::TAG_TYPES.each do |tag_type|
        # get the tags of this type the user has specified
        taglist = tag_set ? eval("tag_set.#{tag_type}_taglist") : []        
        tag_count = taglist.count

        # check if user has chosen the "Any" option
        if self.send("any_#{tag_type}")
          if tag_count > 0
            errors.add(:base, ts("^You have specified tags for %{tag_type} in your %{prompt_type} but also chose 'Any,' which will override them! Please only choose one or the other.", 
                                :tag_type => tag_type, :prompt_type => prompt_type))
          end
          next
        end

        # otherwise let's make sure they offered the right number of tags
        required = eval("restriction.#{tag_type}_num_required")
        allowed = eval("restriction.#{tag_type}_num_allowed")
        unless tag_count.between?(required, allowed)
          taglist_string = taglist.empty? ?
              ts("none") :
              "(#{tag_count}) -- " + taglist.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
          if allowed == 0
            errors.add(:base, ts("^#{prompt_type}: Your #{prompt_type} cannot include any #{tag_type} tags, but you have included %{taglist}.",
              :taglist => taglist_string))
          elsif required == allowed
            errors.add(:base, ts("^#{prompt_type}: Your #{prompt_type} must include exactly %{required} #{tag_type} tags, but you have included #{tag_count} #{tag_type} tags in your current #{prompt_type}.",
              :required => required))
          else
            errors.add(:base, ts("^#{prompt_type}: Your #{prompt_type} must include between %{required} and %{allowed} #{tag_type} tags, but you have included #{tag_count} #{tag_type} tags in your current #{prompt_type}.",
              :required => required, :allowed => allowed))
          end
        end
      end
    end
  end

  # make sure that if there is a specified set of allowed tags, the user's choices
  # are within that set, or otherwise canonical 
  validate :allowed_tags
  def allowed_tags
    restriction = get_prompt_restriction
    if restriction && tag_set
      TagSet::TAG_TYPES.each do |tag_type|
        # if we have a specified set of tags of this type, make sure that all the
        # tags in the prompt are in the set.
        if TagSet::TAG_TYPES_RESTRICTED_TO_FANDOM.include?(tag_type) && restriction.send("#{tag_type}_restrict_to_fandom")
          # skip the check, these will be tested in restricted_tags below
        elsif restriction.has_tags?(tag_type)
          disallowed_taglist = tag_set.send("#{tag_type}_taglist") - restriction.tags(tag_type)
          unless disallowed_taglist.empty?
            errors.add(:base, ts("^These %{tag_type} tags in your %{prompt_type} are not allowed in this challenge: %{taglist}",
              :tag_type => tag_type,
              :prompt_type => self.class.name.downcase,
              :taglist => disallowed_taglist.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)))
          end
        else
          noncanonical_taglist = tag_set.send("#{tag_type}_taglist").reject {|t| t.canonical}
          unless noncanonical_taglist.empty?
            errors.add(:base, ts("^These %{tag_type} tags in your %{prompt_type} are not canonical and cannot be used in this challenge: %{taglist}. To fix this, please contact your challenge moderator who can then log a request with Support for the tags to be made canonical if appropriate.",
              :tag_type => tag_type,
              :prompt_type => self.class.name.downcase,
              :taglist => noncanonical_taglist.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)))
          end
        end
      end
    end
  end
  
  # make sure that if any tags are restricted to fandom, the user's choices are
  # actually in the fandom they have chosen.
  validate :restricted_tags
  def restricted_tags
    restriction = get_prompt_restriction
    if restriction
      TagSet::TAG_TYPES_RESTRICTED_TO_FANDOM.each do |tag_type|
        if restriction.send("#{tag_type}_restrict_to_fandom")
          allowed_tags = tag_type.classify.constantize.with_parents(tag_set.fandom_taglist).canonical
          disallowed_taglist = tag_set ? eval("tag_set.#{tag_type}_taglist") - allowed_tags : []
          # check for tag set associations
          disallowed_taglist.reject! {|tag| TagSetAssociation.where(:tag_id => tag.id, :parent_tag_id => tag_set.fandom_taglist).exists?}
          unless disallowed_taglist.empty?            
            errors.add(:base, ts("^These %{tag_type} tags in your %{prompt_type} are not in the selected fandom(s), %{fandom}: %{taglist} (Your moderator may be able to fix this.)",
                              :prompt_type => self.class.name.downcase,
                              :tag_type => tag_type, :fandom => tag_set.fandom_taglist.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT),
                              :taglist => disallowed_taglist.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)))
          end
        end
      end
    end
  end
  
  # INSTANCE METHODS
      
  # make sure we are not blank
  def blank?
    return false if (url || description)
    tagcount = 0
    [tag_set, optional_tag_set].each do |set|
      if set
        tagcount += set.taglist.size + (TagSet::TAG_TYPES.collect {|type| eval("set.#{type}_taglist.size")}.sum)
      end
    end
    return false if tagcount > 0
    true # everything empty
  end
  
  def can_delete?
    if challenge_signup && !challenge_signup.can_delete?(self)
      false
    else
      true
    end
  end
  
  def unfulfilled_claims
    self.request_claims.unfulfilled_in_collection(self.collection)
  end
  
  def fulfilled_claims
    self.request_claims.fulfilled
  end

  # We want to have all the matching methods defined on
  # TagSet available here, too, without rewriting them,
  # so we just pass them through method_missing
  def method_missing(method)
    super || (tag_set && tag_set.respond_to?(method) ? tag_set.send(method) : super)
  end

  def respond_to?(method, include_private = false)
    super || tag_set.respond_to?(method, include_private)
  end

  # Returns PotentialPromptMatch object if matches, otherwise nil
  # self is the request, other is the offer
  def match(other, settings=nil)
    return nil if settings.nil?
    potential_prompt_match_attributes = {:offer => other, :request => self}
    full_request_tag_set = self.optional_tag_set ? self.tag_set + self.optional_tag_set : self.tag_set
    full_offer_tag_set = other.optional_tag_set ? (other.tag_set + other.optional_tag_set) : other.tag_set

    TagSet::TAG_TYPES.each do |type|
      if self.send("any_#{type}") || other.send("any_#{type}")
        match_count = ALL
      else
        required_count = settings.send("num_required_#{type.pluralize}")
        if settings.send("include_optional_#{type.pluralize}")
          match_count = full_request_tag_set.match_rank(full_offer_tag_set, type)
        else
          # we don't use optional tags to count towards required
          match_count = self.tag_set.match_rank(other.tag_set, type)
        end
      
        # if we have to match all and don't, not a match
        return nil if required_count == ALL && match_count != ALL

        # we are a match only if we either match all or at least as many as required
        return nil if match_count != ALL && match_count < required_count

        # now get the match rank including optional tags if we didn't before
        if !settings.send("include_optional_#{type.pluralize}")
          match_count = full_request_tag_set.match_rank(full_offer_tag_set, type)
        end
      end

      potential_prompt_match_attributes["num_#{type.pluralize}_matched"] = match_count
    end
    return PotentialPromptMatch.new(potential_prompt_match_attributes)
  end

  def get_prompt_restriction
    if collection && collection.challenge
      collection.challenge.prompt_restriction
    else
      nil
    end
  end

  def self.reset_positions_in_collection!(collection)
    minpos = collection.prompts.minimum(:position) - 1
    collection.prompts.by_position.each do |prompt|
      prompt.position = prompt.position - minpos
      prompt.save
    end
  end

  # tag groups
  def tag_groups
    self.tag_set ? self.tag_set.tags.group_by { |t| t.type.to_s } : {}
  end
  
  # Takes an array of tags and returns a comma-separated list, without the markup
  def tag_list(tags)
    tags = tags.uniq.compact
    if !tags.blank? && tags.respond_to?(:collect)
      last_tag = tags.pop
      tag_list = tags.collect{|tag|  tag.name + ", "}.join
      tag_list += last_tag.name
      tag_list.html_safe
    else
      ""
    end
  end
  
  # gets the list of tags for this prompt
  def tag_unlinked_list
    list = ""
    TagSet::TAG_TYPES.each do |type|
      eval("@show_request_#{type}_tags = (self.collection.challenge.request_restriction.#{type}_num_allowed > 0)")
      if eval("@show_request_#{type}_tags") 
          if self && self.tag_set && !self.tag_set.with_type(type).empty?
              list += " - " + tag_list(self.tag_set.with_type(type))
          end
      end   
    end
    return list
  end
  
  def claim_by(user)
    ChallengeClaim.where(:request_prompt_id => self.id, :claiming_user_id => user.id)
  end
  
  # checks if a prompt has been filled in a prompt meme
  def unfulfilled?
    if self.request_claims.empty? || !self.request_claims.fulfilled.exists?
      return true
    end
  end
  
  # currently only prompt meme prompts can be claimed, and by any number of people
  def claimable?
    if self.collection.challenge.is_a?(PromptMeme)
      true
    else
      false
    end
  end
end
