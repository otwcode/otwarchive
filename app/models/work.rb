class Work < ActiveRecord::Base
  has_many :chapters
  has_one :metadata, :as => :described     
  acts_as_commentable
  validates_associated :chapters, :metadata

  def after_save
    @pseud = User.current_user.active_pseud # eventually we will let the user pick
    @pseud.creations << self
  end

end
