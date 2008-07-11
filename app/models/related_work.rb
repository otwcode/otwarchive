class RelatedWork < ActiveRecord::Base 
  belongs_to :work
  belongs_to :parent, :polymorphic => true
end
