class SerialWork < ActiveRecord::Base
  belongs_to :series
  belongs_to :work
end
