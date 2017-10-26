module AdvancedSearchHelper

  def filter_boolean_value(filter_action, tag_type, tag_id)
    if filter_action == "include"
      @search.send("#{tag_type}_ids").present? &&
        @search.send("#{tag_type}_ids").include?(tag_id)
    else
      @search.excluded_tag_ids.present? && @search.excluded_tag_ids.include?(tag_id)
    end
  end
end
