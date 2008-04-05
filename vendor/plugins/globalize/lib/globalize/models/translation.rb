module Globalize # :nodoc:
  class Translation < ActiveRecord::Base  # :nodoc:
    set_table_name "globalize_translations"    

    def self.reloadable?; false end

    belongs_to :language
  end
end
