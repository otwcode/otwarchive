class ExternalCreatorship < ActiveRecord::Base
  belongs_to :external_author
  belongs_to :archivist, :class_name => 'User', :foreign_key => 'archivist_id'
  belongs_to :creation, :polymorphic => true  
end
