class WorkUrl < ApplicationRecord
  METHODS = ['original', 'minimal', 'no_www', 'with_www', 'encoded', 'decoded'].freeze

  belongs_to :work
end
