class CommonTagging < ActiveRecord::Base
  belongs_to :common_tag, :class_name => 'Tag'
  belongs_to :filterable, :polymorphic => true
  
  validates_presence_of :common_tag, :filterable
end
