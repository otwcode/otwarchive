class Metadata < ActiveRecord::Base
  belongs_to :described, :polymorphic => true
  
  validates_length_of :title, :maximum=>255
 
end
