class TagSetOwnership < ActiveRecord::Base
  belongs_to :user
  belongs_to :owned_tag_set
end
