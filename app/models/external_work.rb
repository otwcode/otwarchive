class ExternalWork < ActiveRecord::Base
  has_one :metadata, :as => :described, :dependent => :destroy
  has_many :bookmarks, :as => :bookmarkable
end
