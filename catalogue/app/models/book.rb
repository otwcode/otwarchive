class Book < ActiveRecord::Base
  has_one :publication_data
  validates_presence_of :title, :author, :category, :description
end
