module AdvancedSearchHelper

def advanced_search_string=(term_string)
    terms = []
    self.invalid_terms ||= []
    term_string.split(ArchiveConfig.DELIMITER_FOR_INPUT).each do |string|
      string.squish!
      term = Fandom.find_or_create_by_name(string)
      if term.valid?
        terms << term if term.is_a?(Fandom)
      else
        self.invalid_terms << term
      end
    end
    self.terms = terms
  end

end
