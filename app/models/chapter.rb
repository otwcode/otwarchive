class Chapter < ActiveRecord::Base
  belongs_to :work
  has_one :metadata, :as => :described
  acts_as_commentable
  
  validates_length_of :content, :maximum=>16777215
  
   def set_pseud(pseud_id)
    @pseud = User.current_user.pseuds.find(pseud_id)
    @pseud.creations << self
  end
#  def after_save
#   @pseud = User.current_user.active_pseud # eventually we will let the user pick
#    @pseud.creations << self
#  end
end
