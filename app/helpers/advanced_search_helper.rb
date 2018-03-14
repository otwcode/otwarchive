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

  def filter_boolean_value(filter_action, tag_type, tag_id)
    if filter_action == "include"
      @search.send("#{tag_type}_ids").present? &&
        @search.send("#{tag_type}_ids").include?(tag_id)
    else
      value = @search.excluded_tag_ids.present? && @search.excluded_tag_ids.include?(tag_id)
      if @search.respond_to?(:excluded_bookmark_tag_ids)
        value ||= @search.excluded_bookmark_tag_ids.present? && @search.excluded_bookmark_tag_ids.include?(tag_id)
      end
      value
    end
  end
end
