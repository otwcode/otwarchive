class Metadata < ActiveRecord::Base
  belongs_to :described, :polymorphic => true
end
