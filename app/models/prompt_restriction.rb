class PromptRestriction < ActiveRecord::Base
  has_many :owned_set_taggings, :as => :set_taggable, :dependent => :destroy
  has_many :owned_tag_sets, :through => :owned_set_taggings
  has_many :tag_sets, :through => :owned_tag_sets

  # note: there is no has_one/has_many association here because this class may or may not
  # be used by many different challenge classes. For convenience, if you use this class in
  # a challenge class, add that challenge class to this list so other coders can see where
  # it is used and how it behaves:
  #
  # challenge/gift_exchange
  #

  # VALIDATION
  %w(fandom_num_required category_num_required rating_num_required character_num_required
    relationship_num_required freeform_num_required warning_num_required
    fandom_num_allowed category_num_allowed rating_num_allowed character_num_allowed
    relationship_num_allowed freeform_num_allowed warning_num_allowed).each do |tag_limit_field|
      validates_numericality_of tag_limit_field, :only_integer => true, :less_than_or_equal_to => ArchiveConfig.PROMPT_TAGS_MAX, :greater_than_or_equal_to => 0
  end

  before_validation :update_allowed_values
  # if anything is required make sure it is also allowed
  def update_allowed_values
    self.url_allowed = true if url_required
    self.description_allowed = true if description_required

    TagSet::TAG_TYPES.each do |tag_type|
      required = eval("#{tag_type}_num_required") || eval("self.#{tag_type}_num_required") || 0
      allowed = eval("#{tag_type}_num_allowed") || eval("self.#{tag_type}_num_allowed") || 0
      if required > allowed
        eval("self.#{tag_type}_num_allowed = required")
      end
    end
  end

  def tag_sets_to_add=(tag_set_titles)
    tag_set_titles.split(',').each do |title|
      title.strip!
      ots = OwnedTagSet.find_by_title(title)
      errors.add(:base, ts("We couldn't find the tag set {{title}}.", :title => h(title))) and return if ots.nil?
      errors.add(:base, ts("The tag set {{title}} is not available for public use.", :title => h(title))) and return if (!ots.usable && !ots.user_is_moderator?(User.current_user))
      unless self.owned_tag_sets.include?(ots)
        self.owned_tag_sets << ots
      end
    end
  end
  
  def tag_sets_to_remove=(tag_set_ids)
    tag_set_ids.each do |id|
      ots = OwnedTagSet.find(id)
      if ots && self.owned_tag_sets.include?(ots)
        self.owned_tag_sets -= [ots]
      end
    end
  end

  def tag_sets_to_add; nil; end
  def tag_sets_to_remove; nil; end

  # If the user wants to initialize the tags, let them

  # TagSet::TAG_TYPES_INITIALIZABLE.each do |tag_type|
  #   attr_accessor "#{tag_type}_init_less_than_average".to_sym
  #   attr_accessor "#{tag_type}_init_greater_than_average".to_sym
  #   attr_accessor "#{tag_type}_init_factor".to_sym
  # end

  # after_save :init_tags
  # def init_tags
  #   return if @tag_set_initialized
  #   @tag_set_initialized = true
  #   TagSet::TAG_TYPES_INITIALIZABLE.each do |tag_type|
  #     if self.send("#{tag_type}_init_less_than_average") == "1" || self.send("#{tag_type}_init_greater_than_average") == "1"
  #       initialize_tags(tag_type.classify.constantize, self.send("#{tag_type}_init_factor").to_f, (self.send("#{tag_type}_init_greater_than_average") == "1"))
  #     end
  #   end
  # end

  # tag initialization needs to be able to run in the background
  # def initialize_tags(tag_type, factor, greater_than)
  #   Resque.enqueue(PromptRestriction, self.id, tag_type, factor, greater_than)
  # end
  # @queue = :collection
  # def self.perform(prompt_restriction_id, tag_type, factor, greater_than)
  #   self.initialize_tags_in_background(prompt_restriction_id, tag_type, factor, greater_than)
  # end
  # def self.initialize_tags_in_background(prompt_restriction_id, tag_type, factor, greater_than)
  #   prompt_restriction = PromptRestriction.find(prompt_restriction_id)
  #   prompt_restriction.tag_set ||= TagSet.new
  #   prompt_restriction.tag_set.send("#{tag_type.name.underscore}_tagnames=",
  #             tag_type.with_popularity_relative_to_average(:factor => factor, :greater_than => greater_than, :names_only => true).
  #                         collect(&:name))
  #   prompt_restriction.tag_set.save
  # end

  def has_tags_of_type?(type)
    type = type.classify
    !self.tag_sets.all? {|ts| ts.with_type(type).empty?}
  end

  def tags_of_type(type)
    type = type.classify
    self.tag_sets.collect {|ts| ts.with_type(type)}.flatten.uniq
  end
  
  def tags
    self.tag_sets.inject([]) {|tags, ts| tags << ts.tags}.uniq
  end

end
