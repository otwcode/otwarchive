# frozen_string_literal: true

# A module that provides sortable authors and title.
# Models must have the `pseuds` and `title` attributes.
module Sortable
  extend ActiveSupport::Concern
  
  SORTED_AUTHOR_REGEX = %r{^[\+\-=_\?!'"\.\/]}.freeze

  def authors_to_sort_on
    if self.anonymous?
      "Anonymous"
    else
      self.pseuds.sort.map(&:name).join(",  ").downcase.gsub(SORTED_AUTHOR_REGEX, "")
    end
  end

  def sorted_title
    sorted_title = self.title.downcase.gsub(%r{^["'\./]}, "")
    sorted_title = sorted_title.gsub(/^(an?) (.*)/, '\2, \1')
    sorted_title = sorted_title.gsub(/^the (.*)/, '\1, the')
    sorted_title = sorted_title.rjust(5, "0") if sorted_title.match(/^\d/)
    sorted_title
  end
end
