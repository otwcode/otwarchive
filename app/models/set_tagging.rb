class SetTagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :tag_set
end
