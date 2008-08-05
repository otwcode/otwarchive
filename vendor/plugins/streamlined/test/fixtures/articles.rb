class Article < ActiveRecord::Base
  has_many :authorships, :as => :publication
  has_many :authors, :through => :authorships
end

