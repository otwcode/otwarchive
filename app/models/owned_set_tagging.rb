class OwnedSetTagging < ActiveRecord::Base
  belongs_to :owned_tag_set
  belongs_to :prompt_restriction
end
