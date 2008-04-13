class Chapter < ActiveRecord::Base
  belongs_to :work
  has_one :metadata, :as => :described
  acts_as_commentable
  
  def after_save
    @pseud = User.current_user.active_pseud # eventually we will let the user pick
    @pseud.creations << self
  end
end
