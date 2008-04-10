class Chapter < ActiveRecord::Base
  belongs_to :work
  has_one :metadata, :as => :described
end
