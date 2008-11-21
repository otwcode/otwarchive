class CommonTag < ActiveRecord::Base
  belongs_to :common, :class_name => 'Tag'
  belongs_to :filterable, :polymorphic => true
  
  validates_presence_of :common, :filterable
end
