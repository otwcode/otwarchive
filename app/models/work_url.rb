class WorkUrl < ApplicationRecord
  METHODS = %w(original, minimal, no_www, with_www, encoded, decoded)

  belongs_to :work
end
