class WorkUrl < ApplicationRecord
  METHODS = %w[original minimal no_www with_www encoded decoded].freeze

  belongs_to :work
end
