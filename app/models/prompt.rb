class Prompt < ActiveRecord::Base
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

  # From the custom validations in config/initializers/validations.rb
  validates_url_format_of :url, :allow_blank => true # we validate the presence above, conditionally
  validates_url_active_status_of :url, :allow_blank => true 

  before_validation :cleanup_url
  def cleanup_url
    self.url = reformat_url(self.url) if self.url
  end
  
  def url_required?
    (restriction = get_prompt_restriction) && restriction.url_required
  end

  def description_required?
    (restriction = get_prompt_restriction) && restriction.description_required
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
