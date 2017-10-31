# Shared methods for work and bookmark queries
module TaggableQuery

  def filter_ids
    return @filter_ids if @filter_ids.present?
    @filter_ids = options[:filter_ids] || []
    %w(fandom rating warning category character relationship freeform).each do |tag_type|
      if options["#{tag_type}_ids".to_sym].present?
        ids = options["#{tag_type}_ids".to_sym]
        @filter_ids += ids.is_a?(Array) ? ids : [ids]
      end
    end
    @filter_ids += named_tags
    @filter_ids.uniq
  end

  def exclusion_ids
    return @exclusion_ids if @exclusion_ids.present?
    return if options[:excluded_tag_names].blank? && options[:excluded_tag_ids].blank?

    ids = options[:excluded_tag_ids] || []
    names = options[:excluded_tag_names]&.split(",")
    ids += Tag.where(name: names).pluck(:id) if names
    ids += Tag.where(id: ids).pluck(:merger_id)
    @exclusion_ids = ids.uniq.compact
  end

  # Get the ids for tags passed in by name
  def named_tags
    names = []
    %w(fandom character relationship freeform other_tag).each do |tag_type|
      tag_names_key = "#{tag_type}_names".to_sym
      if options[tag_names_key].present?
        names += options[tag_names_key].split(",")
      end
    end
    Tag.where(name: names).pluck(:id)
  end
end
