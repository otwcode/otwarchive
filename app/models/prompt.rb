class Prompt < ActiveRecord::Base
  
  # number of checkbox options to keep visible by default in form
  OPTIONS_TO_SHOW = 3
  
  belongs_to :collection
  belongs_to :pseud
  has_one :user, :through => :pseud 
  
  belongs_to :tag_set, :dependent => :destroy
  accepts_nested_attributes_for :tag_set
  has_many :tags, :through => :tag_set

  belongs_to :optional_tag_set, :class_name => "TagSet", :dependent => :destroy
  accepts_nested_attributes_for :optional_tag_set
  has_many :optional_tags, :through => :optional_tag_set, :source => :tag

  # VALIDATION
  validates_presence_of :collection_id
  
  # based on the prompt restriction
  validates_presence_of :url, :if => :url_required?
  validates_presence_of :description, :if => :description_required?
  def url_required?
    (restriction = get_prompt_restriction) && restriction.url_required
  end
  def description_required?
    (restriction = get_prompt_restriction) && restriction.description_required
  end

  # From the custom validations in config/initializers/validations.rb
  validates_url_format_of :url, :allow_blank => true # we validate the presence above, conditionally
  # we don't want to disallow temporarily inactive URLs
  # validates_url_active_status_of :url, :allow_blank => true 

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
        required = eval("restriction.#{tag_type}_num_required")
        allowed = eval("restriction.#{tag_type}_num_allowed")
        taglist = tag_set ? eval("tag_set.#{tag_type}_taglist") : []
        tag_count = taglist.count
        unless tag_count.between?(required, allowed)
          taglist_string = taglist.empty? ?  
              t('tag_set.taglist_none', :default => "none") : 
              "(#{tag_count}) -- " + taglist.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
          if allowed == 0
            errors.add_to_base(t("tag_set.#{prompt_type}_#{tag_type}_not_allowed", 
              :default => "#{prompt_type} cannot include any #{tag_type} tags. You currently have {{taglist}}.", 
              :taglist => taglist_string))
          elsif required == allowed
            errors.add_to_base(t("tag_set.#{prompt_type}_#{tag_type}_mismatch", 
              :default => "#{prompt_type} must have exactly {{required}} #{tag_type} tags. You currently have {{taglist}}.", 
              :required => required, :taglist => taglist_string))
          else
            errors.add_to_base(t("tag_set.#{prompt_type}_#{tag_type}_range_mismatch", 
              :default => "#{prompt_type} must have between {{required}} and {{allowed}} #{tag_type} tags. You currently have {{taglist}}.",
              :required => required, :allowed => allowed, :taglist => taglist_string))
          end
        end
      end
    end
  end
  
  validate :allowed_tags
  def allowed_tags
    restriction = get_prompt_restriction
    if restriction
      TagSet::TAG_TYPES.each do |tag_type|
        # if we have a specified set of tags of this type, make sure that all the
        # tags in the prompt are in the set.
        if restriction.has_tags_of_type?(tag_type)
          taglist = tag_set ? (eval("tag_set.#{tag_type}_taglist") - restriction.tag_set.with_type(tag_type.classify)) : []
          unless taglist.empty?
            errors.add_to_base(t("tag_set.specific_#{tag_type}_tags_not_allowed", 
              :default => "These tags are not allowed in this challenge: {{taglist}}",
              :taglist => taglist.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)))
          end
        end
      end
    end
  end

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

  named_scope :in_collection, lambda {|collection| { :conditions => {:collection => collection} }}
  
  named_scope :unused, {:conditions => {:used_up => false}}
  
  # find all matching prompts -- normally will want to chain this with in_collection and unused
  named_scope :matching, lambda {|prompt_to_match|
    {
      :select => "DISTINCT prompts.*",
      :joins => [:tag_sets, :tags],
      :group => 'prompts.id',
      :conditions => ["prompts.id != ? AND tags.id in (?)", prompt_to_match.id, prompt_to_match.tag_set.tags],
      :order => "count(tags.id) desc"
    }
  }

  named_scope :optional_matching, lambda {|prompt_to_match|
    {
      :select => "DISTINCT prompts.*",
      :joins => [:tag_sets, :tags],
      :group => 'prompts.id',
      :conditions => ["prompts.id != ? AND tags.id in (?)", prompt_to_match.id, prompt_to_match.tag_set.tags + prompt_to_match.tag_set.optional_tags],
      :order => "count(tags.id) desc"      
    }    
  }
  
  named_scope :by_user, lambda {|user|
    {
      :conditions => {:user => user}
    }    
  }
  
  named_scope :by_position, {:order => "position ASC", :conditions => "position IS NOT NULL"}
  named_scope :without_position, :conditions => "position IS NULL"
    
    
  # We want to have all the matching methods defined on
  # TagSet available here, too, without rewriting them, 
  # so we just pass them through method_missing
  def method_missing(method, *args, &block)
    if tag_set.respond_to?(method)
      tag_set.send(method, args, block)
    else
      super
    end
  end
  
  def respond_to?(method, include_private = false)
    if tag_set.respond_to?(method)
      true
    else
      super
    end
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

  
end
