class CommonTagging < ActiveRecord::Base
  belongs_to :common_tag, :class_name => 'Tag'
  belongs_to :filterable, :polymorphic => true
  
  validates_presence_of :common_tag, :filterable
  validates_uniqueness_of :common_tag_id, :scope => :filterable_id 
  
  after_create :update_wrangler  
  after_create :inherit_parents 
  
  def update_wrangler
    unless User.current_user.nil?
      common_tag.update_attributes(:last_wrangler => User.current_user)
    end
  end
  
  # A relationship should inherit its characters' fandoms
  def inherit_parents
    if common_tag.is_a?(Relationship) && filterable.is_a?(Character)
      filterable.fandoms.each do |fandom|
        common_tag.add_association(fandom)
      end
    end
  end
end
