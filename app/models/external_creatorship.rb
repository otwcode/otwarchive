class ExternalCreatorship < ActiveRecord::Base
  belongs_to :external_author
  belongs_to :creation, :polymorphic => true  

end
