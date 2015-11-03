class AdminPostTagging < ActiveRecord::Base
  belongs_to :admin_post
  belongs_to :admin_post_tag
end
