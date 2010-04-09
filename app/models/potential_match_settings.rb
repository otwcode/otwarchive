class PotentialMatchSettings < ActiveRecord::Base
  ALL = -1
  REQUIRED_MATCH_OPTIONS =  [
                              [t('potential_match_settings.all', :default => "All"), ALL],  
                              ["0", 0],  
                              ["1", 1],  
                              ["2", 2],  
                              ["3", 3],
                              ["4", 4],
                              ["5", 5]
                            ]

  # VALIDATION
  REQUIRED_TAG_ATTRIBUTES = %w(num_required_fandoms num_required_characters num_required_pairings num_required_freeforms num_required_categories 
     num_required_ratings num_required_warnings)
  
  REQUIRED_TAG_ATTRIBUTES.each do |tag_limit_field|
      validates_numericality_of tag_limit_field, :only_integer => true, :less_than_or_equal_to => ArchiveConfig.PROMPT_TAGS_MAX, :greater_than_or_equal_to => 0
  end

  # must have at least one matching request
  validates_numericality_of :num_required_prompts, :only_integer => true, :less_than_or_equal_to => ArchiveConfig.PROMPTS_MAX, :greater_than_or_equal_to => 1
  
  # are all settings 0
  def no_match_required?
    REQUIRED_TAG_ATTRIBUTES.all? {|attrib| self.send("#{attrib}") == 0}
  end
                           
end
